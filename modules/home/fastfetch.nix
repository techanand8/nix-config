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
        source = "/home/${vars.username}/nix-config/modules/system/plymouth/manx_logo.png"; # Hyper-futuristic custom MANX OS cyberpunk logo!
        type = "auto"; # Seamlessly uses the best terminal protocol (Kitty/Ghostty graphics)
        width = 30;
        height = 15;
        padding = {
          right = 4;
          top = 1;
        };
      };

      # ---------------------------------------------------------------------
      # DISPLAY SETTINGS
      # ---------------------------------------------------------------------
      display = {
        separator = " ▟ "; # Sharp industrial separator
        color = {
          keys = "magenta";
          title = "blue";
        };
      };

      # ---------------------------------------------------------------------
      # SYSTEM DATA MODULES (Highly Structured Dashboard)
      # ---------------------------------------------------------------------
      modules = [
        # --- System Header ---
        {
          type = "title";
          color = {
            user = "blue";
            at = "bright_black";
            host = "magenta";
          };
        }
        {
          type = "custom";
          format = "◆ ─────────────────────────────────────────── ◆";
          font = {
            color = "bright_black";
          };
        }

        # --- Core Operating Environment ---
        {
          type = "os";
          key = "󱄅  System  ";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "󰌢  Kernel  ";
          keyColor = "cyan";
        }
        {
          type = "uptime";
          key = "󰓅  Uptime  ";
          keyColor = "green";
        }
        {
          type = "shell";
          key = "  Shell   ";
          keyColor = "yellow";
        }

        # --- Hardware Engine ---
        {
          type = "custom";
          format = "";
        }
        {
          type = "host";
          key = "󰌢  Machine ";
          keyColor = "blue";
        }
        {
          type = "cpu";
          key = "  CPU     ";
          keyColor = "magenta";
          freqDecimal = 1;
        }
        {
          type = "gpu";
          key = "󰘚  GPU     ";
          keyColor = "red";
        }
        {
          type = "memory";
          key = "  Memory  ";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "󰋊  Storage ";
          keyColor = "yellow";
        }

        # --- Multimedia & Audio Support ---
        {
          type = "custom";
          format = "";
        }
        {
          type = "sound";
          key = "󰎆  Audio   ";
          keyColor = "cyan";
        }
        {
          type = "player";
          key = "󰝚  Player  ";
          keyColor = "magenta";
        }
        {
          type = "song";
          key = "󰎆  Song    ";
          keyColor = "red";
        }

        # --- Footer Block & Palette ---
        {
          type = "custom";
          format = "◆ ─────────────────────────────────────────── ◆";
          font = {
            color = "bright_black";
          };
        }
        "colors"
      ];
    };
  };
}
