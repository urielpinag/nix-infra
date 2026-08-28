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

  ur.hashedPasswordFile = config.age.secrets.ur-nc-s1-hash.path;

  cli.helix.enable = true;

  users.users.root.hashedPasswordFile = config.age.secrets.root-nc-s1-hash.path;

  age.secrets.ur-nc-s1-hash = {
    file = ../../secrets/ur-nc-s1-hash.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  age.secrets.root-nc-s1-hash = {
    file = ../../secrets/root-nc-s1-hash.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
