{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."radarescolar.org" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 80;
        }
      ];
      default = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };
}
