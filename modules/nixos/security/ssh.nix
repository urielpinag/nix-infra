{ config, lib, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = false;

    ports = [ 50777 ];

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowUsers = [ "ur" ];
    };

    extraConfig = ''
      Match Address 100.64.0.0/10
        AllowUsers ur root
        PermitRootLogin yes
        PasswordAuthentication yes
        KbdInteractiveAuthentication yes
    '';

    hostKeys = [
      {
        path = "/etc/ssh/nc-s1-sk";
        type = "ed25519";
      }
    ];
  };

  services.fail2ban = {
    enable = true;
    maxretry = 2;
    bantime = "24h";
    bantime-increment.enable = true;
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "100.64.0.0/10"
    ];
  };
}
