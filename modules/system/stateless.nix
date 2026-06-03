{
  config,
  lib,
  pkgs,
  inputs,
  vars,
  ...
}:

{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  # --- INITIAL RAMDISK WIPING SCRIPT ---
  # This script runs in the very early boot stage (initrd).
  # It mounts the top-level Btrfs partition, deletes the current 'root' subvolume,
  # and recreates it from a blank snapshot.
  boot.initrd.systemd.services.rollback =
    lib.mkIf (vars ? enableImpermanence && vars.enableImpermanence)
      {
        description = "Rollback Btrfs root subvolume to a pristine state";
        wantedBy = [ "initrd.target" ];
        after = [
          "systemd-cryptsetup@cryptsystem.service"
        ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /mnt
          mount -t btrfs -o subvolid=5,noatime,compress=zstd,ssd /dev/mapper/cryptsystem /mnt

          # 1. Self-healing check: If blank snapshot is missing, capture current root first
          if [ ! -e /mnt/blank ]; then
            if [ -e /mnt/root ]; then
              echo "WARNING: /mnt/blank snapshot not found! Capturing current root as blank snapshot..."
              btrfs subvolume snapshot /mnt/root /mnt/blank
            else
              echo "ERROR: Both /mnt/root and /mnt/blank are missing! Creating a new blank subvolume..."
              btrfs subvolume create /mnt/blank
            fi
          fi

          # 2. Perform the cleaning of root
          if [ -e /mnt/root ]; then
            echo "Cleaning root subvolume..."
            # Delete any nested subvolumes (like snapper snapshots) recursively
            btrfs subvolume list -o /mnt/root | cut -f9 -d' ' | while read subvol; do
              echo "Deleting nested subvolume $subvol..."
              btrfs subvolume delete "/mnt/$subvol"
            done
            btrfs subvolume delete /mnt/root
          fi

          # 3. Restore root
          echo "Restoring blank root snapshot..."
          btrfs subvolume snapshot /mnt/blank /mnt/root

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
      "/var/lib/ollama" # Persistent AI models
      "/var/lib/open-webui" # Persistent AI chats and settings
      "/var/lib/flatpak" # Persist system-wide Flatpak apps
      "/tools" # Global Engineering Tools (Xilinx, etc.)
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
    "d /persist/var/lib/ollama 0700 ollama ollama -"
    "d /persist/var/lib/ollama/.ollama 0700 ollama ollama -"
    "Z /persist/var/lib/ollama - ollama ollama -"
    "d /persist/var/lib/open-webui 0700 open-webui open-webui -"
    "Z /persist/var/lib/open-webui - open-webui open-webui -"
  ];

  # Allow non-root users to browse the persistence bind mounts if needed
  fileSystems."/persist".neededForBoot = true;
}
