{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

{
  # =========================================================================
  # DECLARATIVE VPN ORCHESTRATION (The "Nix Final Boss" Way)
  # =========================================================================
  # This module creates a secure, root-owned NetworkManager profile using
  # sops-nix templates. It ensures your corporate VPN is always available,
  # even after a total system wipe.

  sops.secrets = {
    "vpn/maven-silicon/username" = { };
    "vpn/maven-silicon/password" = { };
    "vpn/maven-silicon/gateway" = { };
  };

  # Generate the NetworkManager connection file securely
  sops.templates."MavenSilicon.nmconnection" = {
    # This path is where NetworkManager looks for system-wide connections
    path = "/etc/NetworkManager/system-connections/MavenSilicon.nmconnection";
    mode = "0600"; # Critical: NM ignores files with loose permissions
    owner = "root";
    group = "root";
    restartUnits = [ "NetworkManager.service" ];
    content = ''
      [connection]
      id=MavenSilicon
      uuid=c83d9f1c-7b4a-4e2d-9e1b-8f3d6c5b4a2e
      type=vpn
      autoconnect=false

      [vpn]
      service-type=org.freedesktop.NetworkManager.openconnect
      gateway=${config.sops.placeholder."vpn/maven-silicon/gateway"}
      user=${config.sops.placeholder."vpn/maven-silicon/username"}
      cookie-flags=2
      enable_rsasig=yes
      token_mode=none

      [vpn-secrets]
      password=${config.sops.placeholder."vpn/maven-silicon/password"}

      [ipv4]
      method=auto

      [ipv6]
      addr-gen-mode=default
      method=auto

      [proxy]
    '';
  };

  # Ensure the OpenConnect plugin is installed and registered with NetworkManager
  networking.networkmanager.plugins = [
    pkgs.networkmanager-openconnect
  ];

  # Optional: Also add to systemPackages for CLI usage
  environment.systemPackages = [
    pkgs.networkmanager-openconnect
    pkgs.openconnect
  ];
}
