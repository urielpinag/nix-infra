# Servicio del binario de Radar Escolar (SGE) y despliegue vía CI.
#
# El binario NO lo despliega nixos-rebuild: el CI de SMS-UR lo construye con
# el flake del proyecto (`nix build .#sge-server`), lo inyecta al store con
# `nix copy --to ssh-ng://` y actualiza el symlink /var/lib/sge/current
# (GC root registrado por `nix store add-root`). El servicio apunta siempre
# a ese symlink; `inputs.sge` queda pinneado en el flake como referencia.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.sge = {
    isSystemUser = true;
    group = "sge";
    home = "/var/lib/sge";
  };

  users.groups.sge = { };

  # Usuario de despliegue (GitHub Actions): rsync de la SPA a /var/lib/sge/static
  # y manejo del symlink del binario. Entra por SSH público (puerto 50777).
  users.users.sge-deploy = {
    isSystemUser = true;
    group = "sge-deploy";
    extraGroups = [ "sge" ];
    openssh.authorizedKeys.keys = [
      # Deploy key de GitHub Actions (la privada vive en el secret SSH_DEPLOY_KEY).
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5QxClbQNbLQ0EToIRZOa0WIzyqWCiYKTsYZ7WeMF4s sge-deploy@github-actions"
    ];
  };

  users.groups.sge-deploy = { };

  nix.settings.trusted-users = [ "sge-deploy" ];

  security.sudo.extraRules = [
    {
      groups = [ "sge-deploy" ];
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl restart sge-server";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nix}/bin/nix store add-root /nix/var/nix/gcroots/sge-current *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # /var/lib/sge (data + static servido por nginx). El grupo sge-deploy escribe
  # en static para el rsync del CI; nginx (others) solo lee.
  systemd.tmpfiles.rules = [
    "d /var/lib/sge 0775 sge sge-deploy -"
    "d /var/lib/sge/static 0775 sge sge-deploy -"
  ];

  systemd.services.sge-server = {
    description = "Radar Escolar SGE — Dioxus fullstack (sge-server)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
    ];

    serviceConfig = {
      ExecStart = "/var/lib/sge/current/bin/sge";
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
