{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.tools;
  sharedCfg = config.shared.cli.tools;
in
{
  imports = [ ../../shared/cli/tools.nix ];

  options.cli.tools = {
    enable = lib.mkEnableOption "Herramientas CLI del workstation (lazygit, opencode, lazydocker, mdcat, slumber, pi)";
  };

  config = lib.mkIf cfg.enable {
    shared.cli.tools.enable = true;
    environment.systemPackages = sharedCfg.packages;
  };
}
