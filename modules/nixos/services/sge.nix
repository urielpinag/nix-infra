{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  sgePkg = inputs.sge.packages.x86_64-linux;

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

  users.users.sge-deploy = {
    isSystemUser = true;
    group = "sge-deploy";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
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
