{
  config,
  lib,
  pkgs,
  inputs,
  vars,
  ...
}:

let
  # Toggle this to TRUE only after you have manually created the /persist and /blank subvolumes
  # and moved your data!
  enabled = true;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  # --- INITIAL RAMDISK WIPING SCRIPT ---
  # This script runs in the very early boot stage (initrd).
  # It mounts the top-level Btrfs partition, deletes the current 'root' subvolume,
  # and recreates it from a blank snapshot.
  boot.initrd.systemd.services.rollback = lib.mkIf enabled {
    description = "Rollback Btrfs root subvolume to a pristine state";
    wantedBy = [ "initrd.target" ];
    after = [
      "systemd-cryptsetup@${
        builtins.replaceStrings [ "-" ] [ "\\x2d" ] "luks-${vars.luksSystemUUID}"
      }.service"
    ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      mount -t btrfs -o subvolid=5 /dev/mapper/luks-${vars.luksSystemUUID} /mnt

      if [ -e /mnt/root ]; then
        echo "Cleaning root subvolume..."
        # Delete any nested subvolumes (like snapper snapshots) recursively
        btrfs subvolume list -o /mnt/root | cut -f9 -d' ' | while read subvol; do
          echo "Deleting nested subvolume $subvol..."
          btrfs subvolume delete "/mnt/$subvol"
        done
        btrfs subvolume delete /mnt/root
      fi

      if [ -e /mnt/blank ]; then
        echo "Restoring blank root snapshot..."
        btrfs subvolume snapshot /mnt/blank /mnt/root
      else
        echo "ERROR: /mnt/blank not found! Cannot restore root."
        exit 1
      fi

      umount /mnt
    '';
  };

  # --- SYSTEM PERSISTENCE RULES ---
  # These files/folders are stored on the 'persist' subvolume and symlinked back
  # to their original locations on every boot.
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # Core System State
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/db/sudo/lectured"

      # Hardware & Power State
      "/var/lib/bluetooth"
      "/var/lib/upower"

      # Desktop & Login State
      "/var/lib/sddm" # Login manager settings
      "/var/lib/AccountsService" # User avatars and names

      # Networking & VPN Profiles
      "/etc/NetworkManager" # Persists all Wi-Fi, VPNs, and DHCP leases
      "/etc/wireguard"
      "/etc/openvpn"

      # Security & Secrets
      "/etc/ssh" # Host keys for SSH
      "/var/lib/sops-nix" # System-level SOPS state

      # Virtualization & Containers (System level)
      "/var/lib/libvirt" # VM images/configs
      "/var/lib/docker" # Docker data
      "/var/lib/containerd"
      "/var/lib/containers" # Podman system containers
    ];
    files = [
      # "/etc/adjtime" # If you dual boot with Windows
    ];
  };

  # Manually link the machine-id from persist to avoid impermanence activation collision
  environment.etc."machine-id".source = "/persist/etc/machine-id";

  # --- SECURITY & PERMISSIONS ---
  # Ensure the persistence directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /persist 0755 root root -"
  ];

  # Allow non-root users to browse the persistence bind mounts if needed
  fileSystems."/persist".neededForBoot = true;
}
