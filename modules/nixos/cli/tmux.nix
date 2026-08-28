{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.tmux;

  tmuxConf = ''
    set -g prefix M-a
    unbind C-b
    bind M-a send-prefix

    bind s choose-tree -s -O name

    set -g mouse on
    set -g history-limit 50000
    set -s escape-time 0
    set -g focus-events on

    set -g base-index 1
    setw -g pane-base-index 1
    set -g renumber-windows on

    set -g mode-keys vi
    bind -T copy-mode-vi v send -X begin-selection
    bind -T copy-mode-vi y send -X copy-selection
    bind -T copy-mode-vi y send -X copy-pipe-and-cancel "${cfg.copyCommand}"

    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"

    bind r source-file ~/.tmux.conf \;

    set -g default-terminal "tmux-256color"
    set -as terminal-features ",alacritty:RGB"

    MORADO="#AE90EE"
    OSCURO="#0f0f14"

    set -g status-position bottom
    set -g status-style "bg=''${OSCURO},fg=''${MORADO}"
    set -g status-left-length 30
    set -g status-right-length 60

    set -g status-left "#[fg=''${OSCURO},bg=''${MORADO},bold] #S #[bg=''${OSCURO}] "
    set -g status-right "#[fg=''${MORADO}] #(whoami)@#H "

    set -g window-status-current-format "#[fg=''${OSCURO},bg=''${MORADO},bold] #I #W "
    set -g window-status-format        "#[fg=''${MORADO},bg=''${OSCURO}] #I #W "
    set -g window-status-separator     " "

    set -g pane-border-style        "fg=''${OSCURO}"
    set -g pane-active-border-style "fg=''${MORADO}"

    set -g message-style "bg=''${MORADO},fg=''${OSCURO},bold"
    set -g message-command-style "bg=''${MORADO},fg=''${OSCURO},bold"
  '';
in
{
  options.cli.tmux = {
    enable = lib.mkEnableOption "config de Tmux (programs.tmux)";

    copyCommand = lib.mkOption {
      type = lib.types.str;
      default = "wl-copy";
      description = "Comando usado al copiar en copy-mode (wl-copy en Wayland, xclip en X11).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.tmux ];

    programs.tmux = {
      enable = true;
      extraConfig = tmuxConf;
    };
  };
}
