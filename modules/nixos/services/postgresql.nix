{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    ensureDatabases = [ "sge_prod" ];

    ensureUsers = [
      {
        name = "sge_user";
      }
    ];
  };
}
