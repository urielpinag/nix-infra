{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.starship;
  sharedCfg = config.shared.cli.starship;
in
{
  imports = [ ../../shared/cli/starship.nix ];

  options.cli.starship = {
    enable = lib.mkEnableOption "Starship prompt (tema con paleta Base2Tone Lavender Dark)";
  };

  config = lib.mkIf cfg.enable {
    shared.cli.starship.enable = true;
    environment.systemPackages = sharedCfg.packages;
    environment.etc."starship.toml".text = sharedCfg.config;
    environment.variables.STARSHIP_CONFIG = "/etc/starship.toml";
  };
}
