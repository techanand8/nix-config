{ config, pkgs, vars, ... }:

{
  # =========================================================================
  # ULTIMATE DOCK-HUD FASTFETCH THEME (fastfetch.nix)
  # =========================================================================
  # A highly customized, modern system information hub.
  # Configured to load your hyper-futuristic MANX OS custom emblem in premium
  # resolution, with full hardware, system, and multimedia audio/playback support.

  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      # ---------------------------------------------------------------------
      # LOGO CONFIGURATION (Hyper-Futuristic MANX OS Emblem)
      # ---------------------------------------------------------------------
      logo = {
        source = "${config.home.homeDirectory}/nix-config/modules/system/plymouth/manx_logo.png";
        type = "auto";
        width = 32;
        height = 16;
        padding = {
          right = 4;
        };
      };

      # ---------------------------------------------------------------------
      # DISPLAY SETTINGS (Ambxst Synchronized Style)
      # ---------------------------------------------------------------------
      display = {
        separator = " ┃ "; # Sleek vertical bar
        color = {
          keys = "cyan"; # Ambxst Primary Accent
          title = "magenta"; # Ambxst Secondary Accent
        };
        key = {
          width = 11;
        };
      };

      # ---------------------------------------------------------------------
      # SYSTEM DATA MODULES (Deep Engineering Dashboard)
      # ---------------------------------------------------------------------
      modules = [
        # --- System Identity ---
        {
          type = "title";
          color = {
            user = "magenta";
            at = "white";
            host = "magenta";
          };
        }
        {
          type = "custom";
          format = "──────────────────────────────────────────────";
          font = {
            color = "bright_black";
          };
        }

        # --- Core OS & Hardware ---
        {
          type = "os";
          key = " 󱄅  System ";
          format = "MANX OS ${vars.stateVersion} ({10})";
          keyColor = "cyan";
        }
        {
          type = "kernel";
          key = " 󰌢  Kernel ";
          keyColor = "cyan";
        }
        {
          type = "uptime";
          key = " 󰓅  Uptime ";
          keyColor = "cyan";
        }
        {
          type = "packages";
          key = " 󰏖  Pkgs   ";
          keyColor = "cyan";
        }
        {
          type = "shell";
          key = "   Shell  ";
          keyColor = "cyan";
        }

        # --- Hardware Performance ---
        {
          type = "custom";
          format = "";
        }
        {
          type = "cpu";
          key = "   CPU    ";
          keyColor = "cyan";
        }
        {
          type = "gpu";
          key = " 󰘚  GPU    ";
          keyColor = "cyan";
        }
        {
          type = "memory";
          key = "   Memory ";
          keyColor = "cyan";
        }
        {
          type = "battery";
          key = " 󰁹  Battery";
          keyColor = "cyan";
        }
        {
          type = "disk";
          key = " 󰋊  Disk   ";
          keyColor = "cyan";
        }
        {
          type = "swap";
          key = " 󰓡  Swap   ";
          keyColor = "cyan";
        }

        # --- Network & Media ---
        {
          type = "custom";
          format = "";
        }
        {
          type = "localip";
          key = " 󰩟  LocalIP";
          keyColor = "cyan";
        }
        {
          type = "bios";
          key = " 󰘚  BIOS   ";
          keyColor = "cyan";
        }
        {
          type = "sound";
          key = " 󰎆  Audio  ";
          keyColor = "cyan";
        }
        {
          type = "player";
          key = " 󰝚  Player ";
          keyColor = "cyan";
        }

        # --- Palette ---
        {
          type = "custom";
          format = "──────────────────────────────────────────────";
          font = {
            color = "bright_black";
          };
        }
        "colors"
      ];
    };
  };
}
