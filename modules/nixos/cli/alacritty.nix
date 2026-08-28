{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.alacritty;

  alacrittyConf = ''
    [font]
    size = 11

    [font.normal]
    family = "JetBrainsMono Nerd Font"
    style = "Regular"

    [font.bold]
    family = "JetBrainsMono Nerd Font"
    style = "Bold"

    [font.italic]
    family = "JetBrainsMono Nerd Font"
    style = "Italic"

    [cursor]
    style = { shape = "Beam", blinking = "Never" }

    [window]
    padding = { x = 6, y = 6 }
    decorations = "Full"
    decorations_theme_variant = "Dark"

    [colors.primary]
    background = "#201d2a"
    foreground = "#9992b0"

    [colors.cursor]
    text = "#201d2a"
    cursor = "#b042ff"

    [colors.selection]
    text = "#9992b0"
    background = "#2c2839"

    [colors.normal]
    black = "#201d2a"
    red = "#9375f5"
    green = "#d294ff"
    yellow = "#ecd1ff"
    blue = "#a286fd"
    magenta = "#d294ff"
    cyan = "#b5a0fe"
    white = "#9992b0"

    [colors.bright]
    black = "#625a7c"
    red = "#dba8ff"
    green = "#2c2839"
    yellow = "#4b455f"
    blue = "#6e658b"
    magenta = "#dcd2fe"
    cyan = "#ca80ff"
    white = "#efebff"
  '';
in
{
  options.cli.alacritty = {
    enable = lib.mkEnableOption "Alacritty (config global + tema Base2Tone Lavender Dark)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.alacritty ];

    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    fonts.fontconfig.enable = true;

    environment.etc."alacritty/alacritty.toml".text = alacrittyConf;
    environment.variables.ALACRITTY_CONFIG = "/etc/alacritty/alacritty.toml";
  };
}
