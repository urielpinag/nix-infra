{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 50777 ];
    allowedUDPPorts = [ ];
    trustedInterfaces = [ "tailscale0" ];
  };
}
