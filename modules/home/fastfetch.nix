{ config, pkgs, vars, ... }:

{
  # =========================================================================
  # PROFESSIONAL CYBER-HUD FASTFETCH THEME (fastfetch.nix)
  # =========================================================================
  # A highly customized, modern system information hub.
  # Configured to load your hyper-futuristic MANX OS custom emblem in premium
  # resolution, with full hardware, system, and multimedia audio/playback support.

  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      # ---------------------------------------------------------------------
      # LOGO CONFIGURATION (Transparent Cyber-Cat Emblem)
      # ---------------------------------------------------------------------
      logo = {
        source = "${config.home.homeDirectory}/nix-config/modules/system/plymouth/manx_logo.png";
        type = "auto";
        width = 32; # Slightly optimized for perfect horizontal fit
        height = 16;
        padding = {
          left = 3; # Shift fastfetch layout slightly to center of terminal
          right = 5; # Perfect separation from system specs
          top = 1;
        };
      };

      # ---------------------------------------------------------------------
      # DISPLAY SETTINGS (Ultra-Sleek Engineering Layout)
      # ---------------------------------------------------------------------
      display = {
        separator = " ➜  "; # Styled cyberpunk arrow
        color = {
          keys = "cyan"; # Logic Accent
          title = "red"; # System Accent
          separator = "magenta"; # Cyberpunk Magenta Accent for the arrow!
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
            user = "red";
            at = "white";
            host = "red";
          };
        }
        {
          type = "custom";
          format = "\u001b[90m──────────────────────────────────────────────\u001b[0m";
        }

        # --- Core OS & Environment (Cyan Theme) ---
        {
          type = "os";
          key = " 󱄅  OS      ";
          format = "MANX OS ${vars.stateVersion} ({10})";
          keyColor = "cyan";
        }
        {
          type = "kernel";
          key = " 󰌢  Kernel  ";
          keyColor = "cyan";
        }
        {
          type = "uptime";
          key = " 󰓅  Uptime  ";
          keyColor = "cyan";
        }
        {
          type = "packages";
          key = " 󰏖  Pkgs    ";
          keyColor = "cyan";
        }
        {
          type = "shell";
          key = "   Shell   ";
          keyColor = "cyan";
        }

        # --- Hardware Performance (Red Theme) ---
        {
          type = "custom";
          format = "";
        }
        {
          type = "cpu";
          key = "   CPU     ";
          keyColor = "red";
        }
        {
          type = "gpu";
          key = " 󰘚  GPU     ";
          keyColor = "red";
        }
        {
          type = "memory";
          key = "   Memory  ";
          keyColor = "red";
        }
        {
          type = "battery";
          key = " 󰁹  Battery ";
          keyColor = "red";
        }
        {
          type = "disk";
          key = " 󰋊  Disk    ";
          keyColor = "red";
        }
        {
          type = "swap";
          key = " 󰓡  Swap    ";
          keyColor = "red";
        }

        # --- Network & Media (Green Theme) ---
        {
          type = "custom";
          format = "";
        }
        {
          type = "localip";
          key = " 󰩟  LocalIP ";
          keyColor = "green";
        }
        {
          type = "bios";
          key = " 󰘚  BIOS    ";
          keyColor = "green";
        }
        {
          type = "sound";
          key = " 󰎆  Audio   ";
          keyColor = "green";
        }
        {
          type = "player";
          key = " 󰝚  Player  ";
          keyColor = "green";
        }

        # --- Palette ---
        {
          type = "custom";
          format = "\u001b[90m──────────────────────────────────────────────\u001b[0m";
        }
        "colors"
      ];
    };
  };
}
