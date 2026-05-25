{ config, lib, pkgs, vars, ... }:

{
  # --- INDUSTRIAL POSTGRESQL ENGINE ---
  # This provides a robust database backend for Attic and your VLSI projects.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16; # Use a stable, modern version

    # Ensure the database is stored on the persistent subvolume
    dataDir = "/persist/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";

    # Automated Backup (Safety first for your data)
    backup = {
      enable = true;
      location = "/persist/var/backup/postgresql";
      startAt = "04:00"; # Daily at 4 AM
    };

    # Authentication Configuration
    # Trust local connections for simplicity, but you can harden this later.
    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';

    # Pre-create the Attic database and user
    ensureDatabases = [ "atticd" ];
    ensureUsers = [
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];
  };

  # Ensure persistence directory exists
  systemd.tmpfiles.rules = [
    "d /persist/var/lib/postgresql 0750 postgres postgres -"
    "d /persist/var/backup/postgresql 0750 postgres postgres -"
  ];
}
