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

    ensureDatabases = [ "sge" ];

    ensureUsers = [
      {
        name = "sge_user";
      }
    ];

    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };

  systemd.services.sge-db-prep = {
    description = "Preparar roles de la BD de sge (sge_user superuser, rol sge_app)";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
    };
    script = ''
      PSQL=${pkgs.postgresql_16}/bin/psql
      $PSQL -tAc "ALTER ROLE sge_user WITH SUPERUSER;"
      $PSQL -tAc "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'sge_app') THEN CREATE ROLE sge_app NOLOGIN; END IF; END \$\$;"
      $PSQL -tAc "GRANT sge_app TO sge_user;"
    '';
  };
}
