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

  services.openssh.enable = true;

  services.openssh.hostKeys = [
    {
      type = "rsa";
      bits = 4096;
      path = "/etc/ssh/ssh_host_rsa_key";
    }
    {
      type = "ed25519";
      path = "/etc/ssh/epack-le-hsk";
    }
  ];

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

  users.mutableUsers = false;

  ur.hashedPasswordFile = config.age.secrets.ur-epack-le-hash.path;

  cli.helix.enable = true;
  cli.tmux.enable = true;
  cli.alacritty.enable = true;
  cli.starship.enable = true;
  cli.zsh.enable = true;
  cli.tools.enable = true;
  cli.languages.enable = true;

  services.podman.enable = true;

  age.identityPaths = [
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/epack-le-hsk"
  ];

  age.secrets.ur-epack-le-hash = {
    file = ../../secrets/ur-epack-le-hash.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
