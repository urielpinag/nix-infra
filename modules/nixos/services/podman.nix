{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.podman;
in
{
  options.services.podman = {
    enable = lib.mkEnableOption "Podman rootless + podman-tui + podman-compose";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    environment.systemPackages = with pkgs; [
      podman-tui
      podman-compose
    ];

    users.users.ur.extraGroups = [ "podman" ];
  };
}
