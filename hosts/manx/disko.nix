{ vars, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = vars.mainDisk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            system = {
              priority = 3;
              name = "system";
              size = "100%"; # Dynamic sizing to automatically occupy all remaining space
              content = {
                type = "luks";
                name = "cryptsystem";
                extraOpenArgs = [ "--allow-discards" ];
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [ "tpm2-device=auto" ];
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "subvol=root"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "subvol=home"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "subvol=nix"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "srv" = {
                      mountpoint = "/srv";
                      mountOptions = [
                        "subvol=srv"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "subvol=persist"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "var/lib/portables" = {
                      mountpoint = "/var/lib/portables";
                      mountOptions = [
                        "subvol=var/lib/portables"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "var/lib/machines" = {
                      mountpoint = "/var/lib/machines";
                      mountOptions = [
                        "subvol=var/lib/machines"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "var/tmp" = {
                      mountpoint = "/var/tmp";
                      mountOptions = [
                        "subvol=var/tmp"
                        "compress=zstd:3"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                  };
                };
              };
            };
            swap = {
              priority = 2;
              name = "swap";
              size = "16G"; # Fixed size matching your RAM for hibernation
              content = {
                type = "luks";
                name = "cryptswap";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [ "tpm2-device=auto" ];
                };
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            };
          };
        };
      };
    };
  };
}
