{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.tools;
in
{
  options.cli.tools = {
    enable = lib.mkEnableOption "Herramientas CLI del workstation (lazygit, opencode, lazydocker, mdcat, slumber)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lazygit
      lazydocker
      opencode
      mdcat
      slumber
      wl-clipboard
    ];
  };
}
