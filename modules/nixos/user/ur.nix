{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ur;
in
{
  options.ur = {
    hashedPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Archivo con el hash sha-512 de la contraseña del usuario ur (secret de agenix).";
    };
  };

  config = lib.mkIf (cfg.hashedPasswordFile != null) {
    users.users.ur = {
      isNormalUser = true;
      description = "ur";
      extraGroups = [ "wheel" ];
      hashedPasswordFile = cfg.hashedPasswordFile;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrroIk7zXYrvqtlSN1XXgfX0csTHeDiTEP0jYRklFbe ur@pi-mac.local"
      ];
    };
  };
}
