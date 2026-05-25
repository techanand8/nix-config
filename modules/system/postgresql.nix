{
  config,
  lib,
  pkgs,
  vars,
  ...
}:

{
  # --- INDUSTRIAL POSTGRESQL ENGINE (VLSI WORKSTATION EDITION) ---
  # Provides a high-performance, reliable database for EDA tools and design data.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16; # Latest stable industrial standard

    # Performance Tuning for Engineering Workloads
    settings = {
      max_connections = 100;
      shared_buffers = "1024MB"; # Optimization for workstation RAM
      work_mem = "64MB";
      maintenance_work_mem = "256MB";
      effective_cache_size = "3GB";
    };

    # Ensure data is stored in the persistent subvolume
    dataDir = "/persist/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";

    # Authentication: Secure local trust for the primary user
    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';

    # Create a default database for your VLSI projects
    ensureDatabases = [
      "vlsi_designs"
      "${vars.username}"
    ];
    ensureUsers = [
      {
        name = "${vars.username}";
        ensureDBOwnership = true;
      }
    ];
  };

  # --- AUTOMATED DATA PROTECTION ---
  services.postgresqlBackup = {
    enable = true;
    location = "/persist/var/backup/postgresql";
    startAt = "*-*-* 04:00:00"; # Daily at 4 AM
    databases = [ "vlsi_designs" ];
  };

  # --- PERSISTENCE & PERMISSIONS ---
  systemd.tmpfiles.rules = [
    "d /persist/var/lib/postgresql 0750 postgres postgres -"
    "d /persist/var/lib/postgresql/16 0750 postgres postgres -"
    "d /persist/var/backup/postgresql 0750 postgres postgres -"
  ];
}
