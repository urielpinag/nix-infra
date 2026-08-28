{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.cloudflared = {
    enable = true;

    tunnels."97054c86-c73d-4896-98e5-cd7c5b8ebd3e" = {
      credentialsFile = config.age.secrets.cloudflared-creds.path;

      ingress = {
        "app.radarescolar.org" = "http://localhost:80";
        "pos.mdfzapopan.org" = "http://localhost:80";
      };

      default = "http_status:404";
    };
  };

  age.secrets.cloudflared-creds.file = ../../../secrets/cloudflared-creds.age;
}
