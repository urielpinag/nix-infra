{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.garage = {
    enable = true;
    package = pkgs.garage_1;

    settings = {
      replication_factor = 1;

      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/var/lib/garage/data";

      rpc_bind_addr = "127.0.0.1:3901";

      s3_api = {
        api_bind_addr = "127.0.0.1:3900";
        s3_region = "garage";
      };
    };

    environmentFile = config.age.secrets.garage-rpc-secret.path;
  };

  age.secrets.garage-rpc-secret.file = ../../../secrets/garage-rpc-secret.age;
}
