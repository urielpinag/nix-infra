{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      amass
      cloudflared
      epy
      eza
      git-lfs
      git-xet
      mkpasswd
      nodejs
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
