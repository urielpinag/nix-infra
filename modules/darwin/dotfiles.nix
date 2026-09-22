{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../shared/cli/helix.nix
    ../shared/cli/tmux.nix
    ../shared/cli/starship.nix
    ../shared/cli/tools.nix
    ../shared/languages.nix
  ];

  shared.cli.helix.enable = true;
  shared.cli.tmux.enable = true;
  shared.cli.starship.enable = true;
  shared.cli.tools.enable = true;
  shared.languages.enable = true;

  home.packages =
    config.shared.cli.helix.packages
    ++ config.shared.cli.tmux.packages
    ++ config.shared.cli.starship.packages
    ++ config.shared.cli.tools.packages
    ++ config.shared.languages.packages;

  home.file.".config/helix/config.toml".text = config.shared.cli.helix.configToml;
  home.file.".config/helix/languages.toml".text = config.shared.cli.helix.languagesToml;

  programs.tmux = {
    enable = true;
    extraConfig = config.shared.cli.tmux.config;
  };

  xdg.configFile."starship.toml".text = config.shared.cli.starship.config;
}
