{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.hostName = "epack-le";

  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.displayManager.defaultSession = "gnome";

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    gnome-contacts
    yelp
    gnome-tour
  ];

  services.xserver.excludePackages = [ pkgs.xterm ];

  documentation.doc.enable = false;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    libreoffice
    bitwarden-desktop
  ];

  ur.hashedPassword = "$6$xR4CzZIeEEthFIBB$Ydor0b2xWmBJ/lC/tg3.dF0ahBBEt1.9k7HyYKK0Lg2MgdaQTmFDgXx7jYbCYCCPcygowRkD5eLtf4r2anwDX.";

  cli.helix.enable = true;
  cli.tmux.enable = true;
  cli.alacritty.enable = true;
  cli.starship.enable = true;
  cli.zsh.enable = true;
  cli.tools.enable = true;

  services.podman.enable = true;
}
