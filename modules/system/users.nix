{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

{
  users.mutableUsers = false;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # --- SECURITY & AUTHENTICATION INTEGRATION ---
  # Automatic unlocking of credentials (GNOME Keyring) upon login
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # --- DECLARATIVE SYSTEM WORKSTATION USER ---
  users.users.root = {
    # Ensure root has a password for emergency recovery
    hashedPasswordFile = config.sops.secrets."users/root/password".path;
  };

  users.users."${vars.username}" = {
    isNormalUser = true;
    description = vars.fullName;
    hashedPasswordFile = config.sops.secrets."users/primary-user/password".path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "render"
      "bluetooth" # Required for some Bluetooth UIs/GDBus tools
      "kvm" # VM acceleration
      "libvirtd" # Virtualization system daemon
      "input" # Mouse / touchpad raw input control
      "dialout" # Serial ports & FPGA board programming
      "uucp" # USB-UART serial debugging / VLSI JTAG
      "plugdev" # Raw USB devices & external development boards
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
