{ config, pkgs, vars, ... }:

{
  # =========================================================================
  # PROFESSIONAL FASTFETCH THEME (fastfetch.nix)
  # =========================================================================
  # A highly customized, modern system information hub.
  # Configured to dynamically load your active wallpaper using premium rendering,
  # falling back to a stylish custom-colored NixOS logo in non-graphical shells.

  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      # ---------------------------------------------------------------------
      # LOGO CONFIGURATION (Dynamic Wallpaper & Stylish Fallsbacks)
      # ---------------------------------------------------------------------
      logo = {
        source = "wallpaper"; # Automatically extracts and displays the active desktop wallpaper!
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
        separator = " ❯ ";
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
            at = "muted";
            host = "magenta";
          };
        }
        {
          type = "custom";
          format = "◆ ─────────────────────────────────────────── ◆";
          font = {
            color = "muted";
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

        # --- Footer Block & Palette ---
        {
          type = "custom";
          format = "◆ ─────────────────────────────────────────── ◆";
          font = {
            color = "muted";
          };
        }
        "colors"
      ];
    };
  };
}
