{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # --- XDG Config Files (The Nix Way) ---
  xdg.configFile = {
    # 0. Ambxst System/Idle Config (VLSI Protected)
    "ambxst/config/system.json".text = ''
      {
        "disks": [
          "/"
        ],
        "updateServiceEnabled": true,
        "idle": {
          "general": {
            "lock_cmd": "pkill -f 'alacritty --class manx-screensaver' || true; ambxst lock",
            "before_sleep_cmd": "loginctl lock-session",
            "after_sleep_cmd": "ambxst screen on"
          },
          "listeners": []
        },
        "ocr": {
          "eng": true,
          "spa": true,
          "lat": false,
          "jpn": false,
          "chi_sim": false,
          "chi_tra": false,
          "kor": false
        },
        "recorder": {
          "backend": "gpu-screen-recorder",
          "usePortal": true
        },
        "pomodoro": {
          "workTime": 1500,
          "restTime": 300,
          "autoStart": false,
          "syncSpotify": false
        }
      }
    '';

    # 0.5. Screen Shader for Zen Focus Mode
    "hypr/shaders/grayscale.frag".text = ''
      #version 300 es
      precision mediump float;
      in vec2 v_texcoord;
      uniform sampler2D tex;
      out vec4 fragColor;

      void main() {
          vec4 color = texture(tex, v_texcoord);
          // ITU-R BT.601 standard weights for high-fidelity luminance extraction
          float gray = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
          fragColor = vec4(vec3(gray), color.a);
      }
    '';

    # 1. Main Hyprland Entry Point
    "hypr/hyprland.lua".text = ''
      local home = os.getenv("HOME")
      local config_dir = home .. "/.config/hypr"
      local ambxst_core = home .. "/.local/share/ambxst/hyprland.lua"

      -- 1. SYNC TERMINAL THEMES (Instant update for Ghostty)
      os.execute("bash " .. home .. "/.local/bin/sync_ghostty.sh")

      -- 2. Environment Variables
      dofile(config_dir .. "/hyprland/env.lua")

      -- 3. Core Ambxst Logic
      dofile(ambxst_core)

      -- 5. Local Modular Overrides
      dofile(config_dir .. "/hyprland/input.lua")
      dofile(config_dir .. "/hyprland/execs.lua")
      dofile(config_dir .. "/hyprland/general.lua")
      dofile(config_dir .. "/hyprland/plugins.lua")
      dofile(config_dir .. "/hyprland/rules.lua")
      dofile(config_dir .. "/hyprland/keybinds.lua")
    '';

    # 2. Modular Files
    "hypr/hyprland/input.lua".text = ''
      -- ############ PROFESSIONAL INPUT & TOUCHPAD ############
      hl.config({
          input = {
              kb_layout = "us",
              follow_mouse = 1,
              sensitivity = 0,
              
              -- Professional typing experience
              off_window_axis_events = 1,
              
              touchpad = {
                  natural_scroll = true,
                  disable_while_typing = true,
                  tap_to_click = true,
                  clickfinger_behavior = true,
                  scroll_factor = 0.5,
              },
          },
          
          -- Cursor behavior
          cursor = {
              no_hardware_cursors = false,
              no_break_fs_vrr = false,
              min_refresh_rate = 60,
          },
      })
    '';

    "hypr/hyprland/env.lua".text = ''
      local home_dir = os.getenv("HOME")
      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_SIZE", "24")
      hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
      hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
      hl.env("GDK_BACKEND", "wayland,x11")
      hl.env("QT_QPA_PLATFORM", "wayland;xcb")
      hl.env("SDL_VIDEODRIVER", "wayland,x11")
      hl.env("CLUTTER_BACKEND", "wayland")
      hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
      hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
      hl.env("QT_QPA_PLATFORMTHEME", "kde")
      hl.env("XDG_MENU_PREFIX", "plasma-")
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_TYPE", "wayland")
      hl.env("XDG_SESSION_DESKTOP", "Hyprland")
      local xdg_data_dirs_old = os.getenv("XDG_DATA_DIRS") or ""
      hl.env("XDG_DATA_DIRS", home_dir .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:" .. xdg_data_dirs_old)
    '';

    "hypr/hyprland/execs.lua".text = ''
      hl.on("hyprland.start", function()
          hl.exec_cmd("dbus-update-activation-environment --all")
          hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
          hl.exec_cmd("systemctl --user start graphical-session.target")
          hl.exec_cmd("systemctl --user start hyprpolkitagent")
          hl.exec_cmd("${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init")
          hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
          hl.exec_cmd("bash $HOME/.local/bin/sync_ghostty.sh")
          hl.exec_cmd("bash $HOME/.local/bin/manx-load-plugins &")
          hl.exec_cmd("bash $HOME/.local/bin/manx-shell-load &")
          hl.exec_cmd("hyprctl keyword windowrule 'dimaround, hyprpolkitagent'")
          hl.exec_cmd("sleep 5 && distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/xic/xic &")
      end)
    '';

    "hypr/hyprland/general.lua".text = ''
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
      hl.config({
          general = {
              resize_on_border = true,
          },
          gestures = {
              workspace_swipe_distance = 700,
              workspace_swipe_cancel_ratio = 0.2,
              workspace_swipe_min_speed_to_force = 5,
              workspace_swipe_direction_lock = true,
              workspace_swipe_direction_lock_threshold = 10,
              workspace_swipe_create_new = true
          }
      })
      hl.gesture({ fingers = 3, direction = "swipe", action = "move" })
      hl.gesture({ fingers = 3, direction = "pinch", action = "fullscreen" })
      hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
      hl.gesture({ fingers = 4, direction = "up", action = function() hl.dispatch(hl.dsp.exec_cmd("ambxst run overview")) end })
      hl.gesture({ fingers = 4, direction = "down", action = function() hl.dispatch(hl.dsp.exec_cmd("ambxst run overview")) end })
    '';

    "hypr/hyprland/rules.lua".text = ''
      hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })
      local floating_titles = {
          "^(Open File)(.*)$", "^(Select a File)(.*)$", "^(Choose wallpaper)(.*)$",
          "^(Open Folder)(.*)$", "^(Save As)(.*)$", "^(Library)(.*)$",
          "^(File Upload)(.*)$", "^(.*)(wants to save)$", "^(.*)(wants to open)$"
      }
      for _, title in ipairs(floating_titles) do
          hl.window_rule({ match = { title = title }, float = true })
          hl.window_rule({ match = { title = title }, center = true })
      end
      hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
      hl.window_rule({ match = { class = "^(pavucontrol)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
      hl.window_rule({ match = { class = "^(pavucontrol)$" }, center = true })
      hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
      hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
      hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, center = true })
      hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
      hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
      hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, center = true })
      hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, float = true })
      hl.window_rule({ match = { class = "kcm_.*" }, float = true })
      hl.window_rule({ match = { title = ".*Welcome" }, float = true })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, pin = true })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, move = { "(monitor_w*0.73)", "(monitor_h*0.72)" } })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, size = { "(monitor_w*0.25)", "(monitor_h*0.25)" } })
      hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
      hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })
      hl.window_rule({ match = { float = 0 }, no_shadow = true })

      -- XPPen Tablet Driver (Force X11 compatibility in Hyprland)
      hl.window_rule({ match = { class = "pentablet" }, float = true })
      hl.window_rule({ match = { class = "pentablet" }, center = true })
      hl.window_rule({ match = { class = "pentablet" }, size = { "800", "600" } })

      -- ############ PREMIUM POLKIT PROMPT (High-End UI) ############
      -- This makes your password prompt look like a professional OS element
      hl.window_rule({ match = { class = "hyprpolkitagent" }, float = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, size = { "450", "250" } })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, center = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, pin = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, stay_focused = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, border_size = 2 })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, rounding = 16 })

      -- Force Polkit to use ambxst active border color dynamically
      hl.window_rule({ match = { class = "hyprpolkitagent" }, no_shadow = false })

      -- Glass Effect for Polkit (Matches ambxst bar/menus)
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, blur = true })
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, blur_popups = true })
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, ignore_alpha = 0.5 })
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, no_anim = false })

      -- ############ SILICON SECURITY SCREEN SAVER (Omarchy style) ############
      hl.window_rule({ match = { class = "manx-screensaver" }, float = true })
      hl.window_rule({ match = { class = "manx-screensaver" }, fullscreen = true })
      hl.window_rule({ match = { class = "manx-screensaver" }, no_anim = true })
      hl.window_rule({ match = { class = "manx-screensaver" }, no_shadow = true })

      -- ############ EDA & VLSI ENGINEERING TOOLING WINDOW RULES ############
      -- Float and center all secondary Vivado/Vitis popups and dialog windows
      hl.window_rule({ match = { class = "vivado", title = "^(?!Vivado).*$" }, float = true })
      hl.window_rule({ match = { class = "vivado", title = "^(?!Vivado).*$" }, center = true })
      hl.window_rule({ match = { class = "Vivado", title = "^(?!Vivado).*$" }, float = true })
      hl.window_rule({ match = { class = "Vivado", title = "^(?!Vivado).*$" }, center = true })

      -- Float physical design editors so they don't get squished by tiling layouts
      hl.window_rule({ match = { class = "magic" }, float = true })
      hl.window_rule({ match = { class = "klayout" }, float = true })
      hl.window_rule({ match = { class = "xschem" }, float = true })
      hl.window_rule({ match = { class = "gtkwave" }, float = true })

      -- ############ ELA/VLSI FLOATING ZEN MUSIC WIDGET RULES ############
      -- Float Amberol (minimalist local player) as a beautiful smartphone-like widget
      hl.window_rule({ match = { class = ".*[aA]mberol.*" }, float = true })
      hl.window_rule({ match = { class = ".*[aA]mberol.*" }, size = "360 520" })
      hl.window_rule({ match = { class = ".*[aA]mberol.*" }, center = true })

      -- Float Spotube (premium streaming & offline downloader) as a beautiful dashboard
      hl.window_rule({ match = { class = ".*[sS]potube.*" }, float = true })
      hl.window_rule({ match = { class = ".*[sS]potube.*" }, size = "950 650" })
      hl.window_rule({ match = { class = ".*[sS]potube.*" }, center = true })

      hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })

      -- ############ MULTI-MONITOR WORKSPACE PINNING (EDA/VLSI DUAL-HEAD) ############
      -- Pin primary design workspaces (1-5) to external HDMI display if connected
      for w = 1, 5 do
          hl.workspace_rule({ workspace = tostring(w), monitor = "HDMI-A-1", default = true })
      end

      -- Pin side tool/waveform workspaces (6-10) to internal laptop display (eDP-1)
      for w = 6, 10 do
          hl.workspace_rule({ workspace = tostring(w), monitor = "eDP-1", default = true })
      end
    '';
    "hypr/hyprland/keybinds.lua".text = ''

      hl.bind("SUPER + Q", hl.dsp.window.close())
      hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
      hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"))
      hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("ambxst run tmux"))
      hl.bind("SUPER + ALT + Right", hl.dsp.exec_cmd("resizeactive 50 0"))
      hl.bind("SUPER + ALT + Left", hl.dsp.exec_cmd("resizeactive -50 0"))
      hl.bind("SUPER + ALT + Down", hl.dsp.exec_cmd("resizeactive 0 50"))
      hl.bind("SUPER + ALT + Up", hl.dsp.exec_cmd("resizeactive 0 -50"))
      hl.bind("Print", hl.dsp.exec_cmd("ambxst run screenshot"))
      hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
      hl.bind("SUPER + G", hl.dsp.exec_cmd("bash $HOME/.local/bin/manx-toggle-grayscale"))
    '';

    "hypr/hyprland/plugins.lua".text = ''
      -- Plugins are loaded dynamically at runtime via manx-load-plugins to prevent Ambxst parser conflicts.
    '';

    # 4. Cliamp Config (Winamp retro TUI music player)
    "cliamp/config.toml".text = ''
      # Cliamp - Classic Winamp TUI Music Player Config
      # If no theme is specified, cliamp automatically inherits terminal colors,
      # synchronizing instantly with your active Ambxst theme preset!
      theme = ""
    '';
  };

  # --- Dynamic Theme Synchronization Engine ---
  # Deploys a customized executable to ~/.local/bin/sync_ghostty.sh which is run
  # automatically by Ambxst/Hyprland on every theme or wallpaper update.
  # It dynamically extracts colors from the active Ambxst configuration,
  # writes them to Ghostty/Starship, calculates the luminance of the new wallpaper,
  # and automatically switches system-wide GTK and QT apps between Dark/Light mode!
  home.file.".local/bin/sync_ghostty.sh" = {
    executable = true;
    source = ./scripts/sync_ghostty.sh;
  };

  home.file.".local/bin/manx-load-plugins" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Wait for the Hyprland socket to become fully active
      sleep 1

      # 1. Load the dynamic cursor physics plugin
      hyprctl plugin load ${
        inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
      }/lib/libhypr-dynamic-cursors.so

      # 2. Load the window focus animation plugin
      hyprctl plugin load ${
        inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
      }/lib/libhyprfocus.so

      # 3. Apply configurations for dynamic-cursors
      hyprctl keyword plugin:dynamic-cursors:enabled true
      hyprctl keyword plugin:dynamic-cursors:mode tilt
      hyprctl keyword plugin:dynamic-cursors:shake:enabled true
      hyprctl keyword plugin:dynamic-cursors:shake:nearest true
      hyprctl keyword plugin:dynamic-cursors:shake:threshold 3.0
      hyprctl keyword plugin:dynamic-cursors:shake:timeout 2000
      hyprctl keyword plugin:dynamic-cursors:shake:base 3.0
      hyprctl keyword plugin:dynamic-cursors:hyprcursor:enabled true
      hyprctl keyword plugin:dynamic-cursors:hyprcursor:fallback default

      # 4. Apply configurations for hyprfocus
      hyprctl keyword plugin:hyprfocus:enabled true
      hyprctl keyword plugin:hyprfocus:keyboard_focus_animation flash
      hyprctl keyword plugin:hyprfocus:mouse_focus_animation flash
      hyprctl keyword plugin:hyprfocus:flash:flash_opacity 0.85
      hyprctl keyword plugin:hyprfocus:flash:in_speed 0.5
      hyprctl keyword plugin:hyprfocus:flash:out_speed 3
    '';
  };

  # --- MANX OS Premium Desktop Shell Toggle Engine ---
  # Allows seamless switcher capability between Ambxst, Cartoon-Shell, and Noctalia.
  home.file.".local/bin/manx-shell-toggle" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # MANX OS premium dynamic shell toggle script
      # Handles zero-lag transition between Ambxst, Cartoon, Noctalia, and DMS shells.

      PREF_FILE="$HOME/.config/manx-shell-pref"
      CURRENT_PREF=$(cat "$PREF_FILE" 2>/dev/null || echo "ambxst")

      # Configurable repository for Cartoon Shell (which has no native flake)
      CARTOON_REPO="https://github.com/mailong2401/cartoon-shell.git"

      print_usage() {
          echo -e "\e[1;36m❄️ MANX Shell Engine\e[0m"
          echo -e "Current Active Shell: \e[1;32m$CURRENT_PREF\e[0m\n"
          echo -e "Usage: \e[1mmanx-shell-toggle [ambxst | cartoon]\e[0m"
          echo -e "  - \e[33mambxst\e[0m    : Main Ambxst QML shell (Default)"
          echo -e "  - \e[33mcartoon\e[0m   : Cartoon Shell QuickShell panel"
      }

      if [[ -z "$1" ]]; then
          print_usage
          exit 0
      fi

      TARGET_SHELL=$(echo "$1" | tr '[:upper:]' '[:lower:]')

      case "$TARGET_SHELL" in
          ambxst|cartoon)
              ;;
          *)
              echo -e "\e[1;31mError: Unknown shell target '$1'\e[0m"
              print_usage
              exit 1
              ;;
      esac

      # 1. Save Preference
      mkdir -p "$(dirname "$PREF_FILE")"
      echo "$TARGET_SHELL" > "$PREF_FILE"

      # 2. Notify Switch Start (asynchronously to avoid blocking if notification daemon is hung)
      ${pkgs.libnotify}/bin/notify-send -t 2000 "MANX OS Shell Engine" "Switching desktop layout to: ''${TARGET_SHELL^}..." -i preferences-desktop-theme &

      # Ensure proper QML import path mapping for all shells using stable Nix paths
      export QML2_IMPORT_PATH="${pkgs.qt6.qt5compat.out}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia.out}/lib/qt-6/qml:${pkgs.qt6.qtshadertools.out}/lib/qt-6/qml:${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml:${pkgs.kdePackages.qqc2-desktop-style.out}/lib/qt-6/qml:$QML2_IMPORT_PATH"

      # 3. Safe Shutdown of Current Shell/Quickshell Instances
      # We kill BOTH potential shells to ensure a clean transition without overlapping bars or gaps
      pkill -f quickshell || true
      pkill -f qs || true
      pkill -f ambxst || true
      sleep 0.5

      # 4. Launch Target Shell
      case "$TARGET_SHELL" in
          ambxst)
              ambxst & disown
              ;;
          cartoon)
              CARTOON_PATH="$HOME/.config/quickshell/cartoon-shell"
              if [ ! -d "$CARTOON_PATH" ]; then
                  ${pkgs.libnotify}/bin/notify-send -t 5000 "MANX OS Shell Engine" "Cartoon Shell path not found. Cloning from GitHub..." -i system-run &
                  ${pkgs.git}/bin/git clone "$CARTOON_REPO" "$CARTOON_PATH"
              fi
              quickshell --path "$CARTOON_PATH" & disown
              ;;
      esac

      ${pkgs.libnotify}/bin/notify-send -t 1500 "MANX OS Shell Engine" "''${TARGET_SHELL^} Shell Loaded Successfully!" -i info &
    '';
  };

  home.file.".local/bin/manx-shell-load" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # MANX OS Shell Loader - Invoked at Hyprland Boot
      # Respects user preference saved via manx-shell-toggle.

      PREF_FILE="$HOME/.config/manx-shell-pref"
      TARGET_SHELL=$(cat "$PREF_FILE" 2>/dev/null || echo "ambxst")

      # Use the toggle script to ensure consistent launch logic and setup
      exec bash $HOME/.local/bin/manx-shell-toggle "$TARGET_SHELL"
    '';
  };

  home.file.".local/bin/manx-toggle-grayscale" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      HYPRCTL="${pkgs.hyprland}/bin/hyprctl"
      SHADER_PATH="$HOME/.config/hypr/shaders/grayscale.frag"

      # Dynamic runtime shader toggling
      CURRENT_SHADER=$($HYPRCTL getoption decoration:screen_shader -j | ${pkgs.jq}/bin/jq -r '.str')

      if [[ "$CURRENT_SHADER" == "none" || "$CURRENT_SHADER" == "" ]]; then
          $HYPRCTL eval 'hl.config({ decoration = { screen_shader = "'"$SHADER_PATH"'" } })'
          ${pkgs.libnotify}/bin/notify-send -t 1500 "Zen Focus Mode" "Grayscale screen filter active" -i info
      else
          $HYPRCTL eval 'hl.config({ decoration = { screen_shader = "" } })'
          ${pkgs.libnotify}/bin/notify-send -t 1500 "Zen Focus Mode" "Standard color profile restored" -i info
      fi
    '';
  };

  # Install Bibata Cursors package locally so they can be loaded by Hyprland envs,
  # but without setting home.pointerCursor globally (so KDE stays untouched).
  home.packages = [
    pkgs.bibata-cursors
    pkgs.terminaltexteffects
    pkgs.chafa
    pkgs.spotube # Premium streaming & offline music downloader
    pkgs.amberol # Breathtaking minimalist local GTK4 offline player

    # Cliamp: The ultimate retro Winamp-inspired TUI terminal music player!
    (pkgs.stdenv.mkDerivation rec {
      pname = "cliamp";
      version = "1.56.0";

      src = pkgs.fetchurl {
        url = "https://github.com/bjarneo/cliamp/releases/download/v${version}/cliamp-linux-amd64";
        sha256 = "07d0f8araglg5rw64h6rq34s36ah1b90mq0d5gxrqr5frns7hd1s";
      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/cliamp
        chmod +x $out/bin/cliamp
      '';
    })
  ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Secure direct lock with cool effects
        lock_cmd = "ambxst lock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "ambxst screen on";
      };

      listener = [
        {
          # 1. Dim Brightness (2.5 mins)
          timeout = 150;
          on-timeout = "ambxst brightness 10 -s";
          on-resume = "ambxst brightness -r";
        }
        {
          # 2. Launch Visual Screensaver (4 mins)
          timeout = 240;
          on-timeout = "${config.home.homeDirectory}/.local/bin/manx-screensaver";
          # We removed on-resume pkill here because the script handles its own exit.
          # This prevents the 'immediate kill' jitter when the window gains focus.
        }
        {
          # 3. Secure Lock (5 mins)
          timeout = 300;
          on-timeout = "pkill -f 'alacritty --class manx-screensaver' || true; loginctl lock-session";
        }
        {
          # 4. Power Save / Screen Off (5.5 mins)
          timeout = 330;
          on-timeout = "ambxst screen off";
          on-resume = "ambxst screen on";
        }
      ];
    };
  };

  # Ensure hypridle starts with the graphical session
  systemd.user.services.hypridle.Install.WantedBy = [ "graphical-session.target" ];

  # Custom Silicon Security Screensaver (Elite Omarchy style)
  home.file.".local/bin/manx-screensaver" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Omarchy-standard Screensaver Orchestrator
      LOG_FILE="/tmp/manx-screensaver.log"

      # 0. PRE-FLIGHT
      if [[ -f "$HOME/.local/state/omarchy/toggles/screensaver-off" ]]; then
          echo "$(date): [Orchestrator] Disabled via toggle" >> "$LOG_FILE"
          exit 0
      fi

      # 1. CHECK INHIBITION
      if [[ "$1" != "--force" ]]; then
          if [[ "$(axctl system is-inhibited 2>/dev/null)" == "true" ]] || \
             [[ "$(axctl system is-inhibited 2>/dev/null)" == "\"true\"" ]] || \
             axctl system media-inhibit-check 2>/dev/null | grep -q '"count": [1-9]'; then
              echo "$(date): [Orchestrator] System inhibited" >> "$LOG_FILE"
              exit 0
          fi
      fi

      # 2. CLEANUP & LAUNCH
      ${pkgs.procps}/bin/pkill -f "alacritty --class manx-screensaver" || true
      sleep 0.2

      echo "$(date): [Orchestrator] Launching Alacritty..." >> "$LOG_FILE"
      LC_ALL=C ${pkgs.alacritty}/bin/alacritty --class manx-screensaver \
                --title Screensaver \
                -o "window.startup_mode='Fullscreen'" \
                -o "window.decorations='None'" \
                -o "colors.primary.background='#000000'" \
                --command "$HOME/.local/bin/manx-screensaver-run"
    '';
  };

  home.file.".local/bin/manx-screensaver-run" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Screensaver Core Loop (Elite Silicon Grade)
      LOG_FILE="/tmp/manx-screensaver.log"

      # Absolute tool paths for Nix stability
      HYPRCTL="${pkgs.hyprland}/bin/hyprctl"
      JQ="${pkgs.jq}/bin/jq"
      TTE="${pkgs.terminaltexteffects}/bin/tte"
      CHAFA="${pkgs.chafa}/bin/chafa"
      TPUT="${pkgs.ncurses}/bin/tput"
      PKILL="${pkgs.procps}/bin/pkill"
      FREE="${pkgs.procps}/bin/free"

      START_TIME=$(awk '{print int($1)}' /proc/uptime)
      INITIAL_CURSOR=$($HYPRCTL cursorpos 2>/dev/null || echo "0, 0")

      exit_screensaver() {
          local reason=$1
          echo "$(date): [Core] Exit triggered by: $reason" >> "$LOG_FILE"
          $HYPRCTL keyword cursor:invisible false >/dev/null 2>&1
          $PKILL -P $$ 2>/dev/null
          $PKILL -f "alacritty --class manx-screensaver" 2>/dev/null
          exit 0
      }

      trap "exit_screensaver 'Signal'" SIGINT SIGTERM EXIT
      $HYPRCTL keyword cursor:invisible true >/dev/null 2>&1

      # WAIT FOR FULLSCREEN SETTLE (Prevents cropping)
      # Alacritty takes a moment to map the true fullscreen resolution.
      sleep 0.5

      echo "$(date): [Core] Started at $INITIAL_CURSOR" >> "$LOG_FILE"

      # Branding
      LOGO_PATH="$HOME/.config/omarchy/branding/logo.png"
      TEXT_PATH="$HOME/.config/omarchy/branding/screensaver.txt"

      while true; do
          # Re-detect dimensions every loop for safety
          cols=$($TPUT cols)
          rows=$($TPUT lines)

          # Force a minimum settle for first launch
          if [[ $cols -le 80 ]]; then
             sleep 0.3
             cols=$($TPUT cols)
             rows=$($TPUT lines)
          fi
          if [[ -f "$LOGO_PATH" ]]; then
              target_cols=$((cols * 8 / 10))
              target_rows=$((rows * 7 / 10))
              LOGO_TEXT=$($CHAFA --format=symbols --size=''${target_cols}x''${target_rows} "$LOGO_PATH")
          elif [[ -f "$TEXT_PATH" ]]; then
              LOGO_TEXT=$(awk 'NF {p=1} p' "$TEXT_PATH" | tac | awk 'NF {p=1} p' | tac)
          else
              CPU=$(grep 'cpu ' /proc/stat | awk '{u=($2+$4)*100/($2+$4+$5)} END {printf "%.1f%%", u}')
              MEM=$($FREE -m | awk '/Mem:/ { printf "%.0f%%", $3/$2*100 }')
              LOGO_TEXT="⚡ MANX OS ⚡\n[ SILICON WORKSTATION ]\n\nCPU: $CPU | RAM: $MEM\nSTATUS: ENCRYPTED"
          fi

          effects=("beams" "binarypath" "blackhole" "bubbles" "burn" "colorshift" "matrix" "rain" "slide" "waves")
          effect=''${effects[$RANDOM % ''${#effects[@]}]}

          echo "$(date): [Core] Running $effect..." >> "$LOG_FILE"

          # Run TTE and capture errors to the main log
          echo -e "$LOGO_TEXT" | $TTE --frame-rate 60 --xterm-colors --no-restore-cursor \
                                      --canvas-width "$cols" --canvas-height "$rows" \
                                      --anchor-canvas c --anchor-text c --no-eol "$effect" 2>> "$LOG_FILE" &
          TTE_PID=$!

          # Interaction Loop
          while kill -0 "$TTE_PID" 2>/dev/null; do
              # 1. Keypress check (High-speed)
              if read -n 1 -t 0.05; then
                  exit_screensaver "Keypress"
              fi

              # Snappy grace period (2s instead of 5s)
              uptime_s=$(awk '{print int($1)}' /proc/uptime)
              if [[ $((uptime_s - START_TIME)) -gt 2 ]]; then
                  # 2. Focus check
                  active=$($HYPRCTL activewindow -j | $JQ -r '.class' 2>/dev/null)
                  if [[ "$active" != "manx-screensaver" ]]; then
                      exit_screensaver "Focus Lost"
                  fi
                  # 3. Cursor check
                  current=$($HYPRCTL cursorpos 2>/dev/null || echo "0, 0")
                  if [[ "$current" != "$INITIAL_CURSOR" ]]; then
                      exit_screensaver "Movement"
                  fi
              fi
          done

          sleep 0.1
          clear

      done
    '';
  };

}
