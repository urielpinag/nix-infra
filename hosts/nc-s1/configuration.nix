{
  config,
  lib,
  pkgs,
  ...
}:
let
  iface = "ens3";
in
{
  networking.hostName = "nc-s1";

  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = false;

  networking.interfaces.${iface} = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "152.53.38.88";
        prefixLength = 22;
      }
    ];
    ipv6.addresses = [
      {
        address = "2a0a:4cc0:2000:a18::1";
        prefixLength = 64;
      }
    ];
  };

  networking.defaultGateway = "152.53.36.1";
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = iface;
  };

  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
    "2606:4700:4700::1111"
  ];

  users.users.ur = {
    isNormalUser = true;
    description = "admin";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$6Rqun66S538llF2G$kssYiyWTytsM57OGoFzVkv4eegmBl6.xI5femDLVIWtZQoFgLvXA3k51PJu6SMLG9pKTNDEWShwpBVXdnA.J..";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrroIk7zXYrvqtlSN1XXgfX0csTHeDiTEP0jYRklFbe ur@pi-mac.local"
    ];
  };

  users.users.root.hashedPassword = "$6$kEze9Ox7aShQ/hEH$x3DADuSOkVbNkZf/W8MEedAnqiLKcdP9NTGxgm.ZOL59k3Ty.UoEWiEp.JpLFPKQbfmm/4.gG6MBSmEkhfX1a1";
}
