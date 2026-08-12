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
    hashedPassword = lib.mkOption {
      type = lib.types.str;
      description = "Hash de la contraseña del usuario ur (generar con mkpasswd -m sha-512).";
    };
  };

  config = lib.mkIf (cfg.hashedPassword != "") {
    users.users.ur = {
      isNormalUser = true;
      description = "ur";
      extraGroups = [ "wheel" ];
      hashedPassword = cfg.hashedPassword;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrroIk7zXYrvqtlSN1XXgfX0csTHeDiTEP0jYRklFbe ur@pi-mac.local"
      ];
    };
  };
}
