{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.starship;

  starshipConf = ''
    format = "$directory$git_branch$git_status$character"

    [directory]
    truncation_length = 3
    style = "bold #b5a0fe"
    read_only = " ro"

    [git_branch]
    symbol = ""
    style = "bold #d294ff"

    [git_status]
    style = "#d294ff"

    [character]
    success_symbol = "[❯](bold #b042ff)"
    error_symbol = "[❯](bold #9375f5)"
    vicmd_symbol = "[❮](bold #d294ff)"
  '';
in
{
  options.cli.starship = {
    enable = lib.mkEnableOption "Starship prompt (tema con paleta Base2Tone Lavender Dark)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.starship ];

    environment.etc."starship.toml".text = starshipConf;
    environment.variables.STARSHIP_CONFIG = "/etc/starship.toml";
  };
}
