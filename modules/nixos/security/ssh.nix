{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ssh;
in
{
  options.ssh = {
    hostKeyPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Ruta del host key ed25519 de SSH. Si es null se usan los host keys por defecto.";
    };
  };

  config = {
    services.openssh = {
      enable = true;
      openFirewall = false;

      ports = [ 50777 ];

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        AllowUsers = [
          "ur"
          "sge-deploy"
        ];
      };

      extraConfig = ''
        Match Address 100.64.0.0/10
          AllowUsers ur root
          PermitRootLogin yes
          PasswordAuthentication yes
          KbdInteractiveAuthentication yes
      '';

      hostKeys = lib.mkIf (cfg.hostKeyPath != null) [
        {
          path = cfg.hostKeyPath;
          type = "ed25519";
        }
      ];
    };

    services.fail2ban = {
      enable = true;
      maxretry = 2;
      bantime = "24h";
      bantime-increment.enable = true;
      ignoreIP = [
        "127.0.0.1/8"
        "::1"
        "100.64.0.0/10"
      ];
    };
  };
}
