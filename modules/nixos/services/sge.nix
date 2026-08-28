# Servicio de Radar Escolar (SGE): el binario y la SPA vienen del flake de la
# app (`inputs.sge`) y se despliegan con `nixos-rebuild switch` — ambos son
# parte del closure del sistema (sin symlinks ni GC roots manuales).
#
# El deploy lo dispara el GitHub Action de nix-infra: hace SSH como `sge-deploy`
# (puerto 50777) y corre `sudo sge-deploy`, que actualiza el checkout de
# nix-infra, el input `sge` y reconstruye el sistema en el propio servidor.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  sgePkg = inputs.sge.packages.x86_64-linux;

  # Scripts de despliegue (corren como root vía sudo NOPASSWD). Requieren un
  # checkout de nix-infra en /home/ur/.config/nix-infra y que root tenga acceso SSH a
  # GitHub (llave del servidor autorizada en la cuenta) para el fetch de los
  # inputs privados.
  #
  # sge-deploy: para una versión nueva de la app (lo dispara el action Deploy
  # de SMS-UR). Actualiza el input `sge` al último commit de la app.
  # sge-deploy-infra: para cambios de infra (push a main de nix-infra). No toca
  # el input `sge`; reconstruye con el commit ya fijado en el flake.lock.
  sgeDeployScript = pkgs.writeShellScriptBin "sge-deploy" ''
    set -euo pipefail
    export PATH=/run/current-system/sw/bin:$PATH
    cd /home/ur/.config/nix-infra
    git pull --ff-only
    nix flake update sge
    nixos-rebuild switch --flake .#nc-s1
  '';

  sgeDeployInfraScript = pkgs.writeShellScriptBin "sge-deploy-infra" ''
    set -euo pipefail
    export PATH=/run/current-system/sw/bin:$PATH
    cd /home/ur/.config/nix-infra
    git pull --ff-only
    nixos-rebuild switch --flake .#nc-s1
  '';
in
{
  users.users.sge = {
    isSystemUser = true;
    group = "sge";
    home = "/var/lib/sge";
  };

  users.groups.sge = { };

  environment.systemPackages = [ sgeDeployScript sgeDeployInfraScript ];

  # Usuario de despliegue (GitHub Actions): entra por SSH (puerto 50777) y solo
  # puede correr el script de despliegue con sudo.
  users.users.sge-deploy = {
    isSystemUser = true;
    group = "sge-deploy";
    # Sin shell, OpenSSH rechaza ejecutar comandos ("This account is currently
    # not available") y el GitHub Action no puede correr `nix copy` ni sudo.
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      # Deploy key de GitHub Actions (la privada vive en el secret SSH_DEPLOY_KEY).
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtw1CdsQHmG3CRBUrNwR/n8DYHHKG99+/faVNs6w4ZJ sge-deploy@github-actions"
    ];
  };

  users.groups.sge-deploy = { };

  nix.settings.trusted-users = [ "sge-deploy" ];

  security.sudo.extraRules = [
    {
      groups = [ "sge-deploy" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/sge-deploy";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/sge-deploy-infra";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # /var/lib/sge: datos de la app (almacenamiento local si no se usa S3).
  systemd.tmpfiles.rules = [
    "d /var/lib/sge 0775 sge sge-deploy -"
  ];

  systemd.services.sge-server = {
    description = "Radar Escolar SGE — Dioxus fullstack (sge-server)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
      "sge-db-prep.service"
    ];
    requires = [ "sge-db-prep.service" ];

    serviceConfig = {
      ExecStart = "${sgePkg.sge-server}/bin/sge";
      User = "sge";
      Group = "sge";
      WorkingDirectory = "/var/lib/sge";
      EnvironmentFile = config.age.secrets.sge-env.path;
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      ProtectSystem = "full";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  age.secrets.sge-env = {
    file = ../../../secrets/sge-env.age;
    owner = "sge";
    group = "sge";
    mode = "0400";
  };
}
