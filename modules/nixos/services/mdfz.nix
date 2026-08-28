# Servicio del POS (mdfz-pos): app Node (SvelteKit/adapter-node) que viene del
# flake de la app (`inputs.mdfz`) y se despliega con `nixos-rebuild switch` —
# el paquete es parte del closure del sistema (sin symlinks ni GC roots
# manuales).
#
# El deploy lo dispara el GitHub Action de mdfz-pos: hace SSH como `mdfz-deploy`
# (puerto 50777) y corre `sudo mdfz-deploy`, que actualiza el checkout de
# nix-infra, el input `mdfz` (con `nix flake lock --update-input mdfz`, sin
# arrastrar nixpkgs para que el closure que compiló GitHub coincida con lo que
# evalúa el servidor) y reconstruye el sistema en el propio servidor.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  posPkg = inputs.mdfz.packages.x86_64-linux.pos;

  # Scripts de despliegue (corren como root vía sudo NOPASSWD). Requieren un
  # checkout de nix-infra en /var/lib/nix-infra y que root tenga acceso SSH a
  # GitHub (llave del servidor autorizada en la cuenta) para el fetch de los
  # inputs privados.
  #
  # mdfz-deploy: para una versión nueva de la app (lo dispara el action Deploy
  # de mdfz-pos). Actualiza el input `mdfz` al último commit de la app.
  # mdfz-deploy-infra: para cambios de infra (push a main de nix-infra). No toca
  # el input `mdfz`; reconstruye con el commit ya fijado en el flake.lock.
  mdfzDeployScript = pkgs.writeShellScriptBin "mdfz-deploy" ''
    set -euo pipefail
    export PATH=/run/current-system/sw/bin:$PATH
    cd /var/lib/nix-infra
    git pull --ff-only
    nix flake lock --update-input mdfz
    nixos-rebuild switch --flake .#nc-s1
  '';

  mdfzDeployInfraScript = pkgs.writeShellScriptBin "mdfz-deploy-infra" ''
    set -euo pipefail
    export PATH=/run/current-system/sw/bin:$PATH
    cd /var/lib/nix-infra
    git pull --ff-only
    nixos-rebuild switch --flake .#nc-s1
  '';
in
{
  users.users.mdfz = {
    isSystemUser = true;
    group = "mdfz";
    home = "/var/lib/mdfz-pos";
  };

  users.groups.mdfz = { };

  environment.systemPackages = [ mdfzDeployScript mdfzDeployInfraScript ];

  # Usuario de despliegue (GitHub Actions): entra por SSH (puerto 50777) y solo
  # puede correr los scripts de despliegue con sudo.
  users.users.mdfz-deploy = {
    isSystemUser = true;
    group = "mdfz-deploy";
    openssh.authorizedKeys.keys = [
      # Deploy key de GitHub Actions de mdfz-pos (la privada vive en el secret
      # SSH_DEPLOY_KEY de ese repo).
      "ssh-ed25519 PLACEHOLDER_ADD_MDFZ_DEPLOY_PUBKEY mdfz-deploy@github-actions"
    ];
  };

  users.groups.mdfz-deploy = { };

  nix.settings.trusted-users = [ "mdfz-deploy" ];

  security.sudo.extraRules = [
    {
      groups = [ "mdfz-deploy" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/mdfz-deploy";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/mdfz-deploy-infra";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # /var/lib/mdfz-pos: WorkingDirectory de la app (sin datos propios; la BD vive
  # en el postgres local).
  systemd.tmpfiles.rules = [
    "d /var/lib/mdfz-pos 0775 mdfz mdfz-deploy -"
  ];

  # Aplica el esquema (drizzle-kit push) y el seed antes de levantar la app.
  # El seed usa onConflictDoNothing, así que es idempotente en cada deploy.
  systemd.services.pos-db-prep = {
    description = "Aplicar esquema y seed de la BD de mdfz-pos";
    after = [
      "postgresql.service"
      "pos-db-roles.service"
    ];
    requires = [
      "postgresql.service"
      "pos-db-roles.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "mdfz";
      Group = "mdfz";
      EnvironmentFile = config.age.secrets.mdfz-env.path;
      ExecStart = "${posPkg}/bin/pos-db-prep";
    };
  };

  systemd.services.mdfz-pos = {
    description = "mdfz-pos — Punto de venta (SvelteKit/adapter-node)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
      "pos-db-prep.service"
    ];
    requires = [ "pos-db-prep.service" ];

    serviceConfig = {
      ExecStart = "${posPkg}/bin/pos";
      User = "mdfz";
      Group = "mdfz";
      WorkingDirectory = "/var/lib/mdfz-pos";
      EnvironmentFile = config.age.secrets.mdfz-env.path;
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      ProtectSystem = "full";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  age.secrets.mdfz-env = {
    file = ../../../secrets/mdfz-env.age;
    owner = "mdfz";
    group = "mdfz";
    mode = "0400";
  };
}
