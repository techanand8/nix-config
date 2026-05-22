{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

{
  # --- SECURITY & AUTHENTICATION INTEGRATION ---
  # Automatic unlocking of credentials (GNOME Keyring) upon login
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # --- DECLARATIVE SYSTEM WORKSTATION USER ---
  users.users."${vars.username}" = {
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "render"
    ];
    shell = pkgs.zsh;

    # Namespace maps required to enable Rootless distrobox/podman virtualization layers
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };
}
