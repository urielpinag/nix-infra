{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.tmux;
  sharedCfg = config.shared.cli.tmux;
in
{
  imports = [ ../../shared/cli/tmux.nix ];

  options.cli.tmux = {
    enable = lib.mkEnableOption "Config de Tmux (programs.tmux)";

    copyCommand = lib.mkOption {
      type = lib.types.str;
      default = "wl-copy";
      description = "Comando usado al copiar en copy-mode (wl-copy en Wayland, xclip en X11).";
    };
  };

  config = lib.mkIf cfg.enable {
    shared.cli.tmux.enable = true;
    shared.cli.tmux.copyCommand = cfg.copyCommand;
    environment.systemPackages = sharedCfg.packages;

    programs.tmux = {
      enable = true;
      extraConfig = sharedCfg.config;
    };
  };
}
