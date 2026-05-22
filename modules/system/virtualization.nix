{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

{
  # --- VMWARE WORKSTATION HYPERVISOR LAYERS ---
  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.host.extraConfig = ''
    # Advanced Keymap Support
    xkeymap.useLocalxkb = "TRUE"
    xkeymap.nokeycodeMap = "TRUE"

    # USB Passthrough (HID/Mice/Keyboards)
    usb.generic.allowHID = "TRUE"
    usb.generic.allowLastHID = "TRUE"
  '';

  # --- ROOTLESS VIRTUAL CONTAINER RUNTIMES (Distrobox Backing) ---
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
