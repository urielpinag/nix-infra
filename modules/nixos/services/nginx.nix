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

      # Dioxus fullstack SSR: el server sirve el HTML hidratado, los assets
      # (public/) y la API. nginx solo proxya para mantener el TLS/edge de
      # cloudflared. Servir la SPA estática rompe la hidratación del cliente
      # (falta window.initial_dioxus_hydration_data).
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };
}
