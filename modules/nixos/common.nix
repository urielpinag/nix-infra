{
  config,
  lib,
  pkgs,
  ...
}:
{
  time.timeZone = "America/Mexico_City";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    helix
    vim
    htop
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
}
