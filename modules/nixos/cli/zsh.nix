{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.zsh;
in
{
  options.cli.zsh = {
    enable = lib.mkEnableOption "Zsh como shell de ur + prompt Starship + aliases";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableLsColors = true;
      interactiveShellInit = ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
        alias ls='${pkgs.eza}/bin/eza -l --icons=always --group-directories-first'
        export EDITOR="hx"
      '';
    };

    environment.systemPackages = with pkgs; [
      eza
    ];

    users.users.ur.shell = pkgs.zsh;
  };
}
