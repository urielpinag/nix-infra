{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
