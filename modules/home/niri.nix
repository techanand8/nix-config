{ pkgs, ... }:

{
  # --- NIRI DESKTOP CONFIGURATION ---
  # Declarative deployment of niri config to ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".text = ''
    // ############ INPUT SYSTEMS ############
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            dwt
            natural-scroll
            click-method "clickfinger"
            scroll-factor 0.5
        }
    }

    // ############ OUTPUTS (MONITORS) ############
    output "HDMI-A-1" {
        scale 1.0
    }
    output "eDP-1" {
        scale 1.0
    }

    // ############ CURSOR & THEME SYNC ############
    cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 24
    }

    environment {
        XCURSOR_THEME "Bibata-Modern-Classic"
        XCURSOR_SIZE "24"
        QT_QPA_PLATFORM "wayland"
        ELECTRON_OZONE_PLATFORM_HINT "auto"
    }

    // ############ VISUAL STYLE & LAYOUT ############
    layout {
        gaps 8
        center-focused-column "never"
        
        preset-column-widths {
            proportion 0.333
            proportion 0.5
            proportion 0.667
        }
        
        default-column-width { proportion 0.5; }
        
        focus-ring {
            width 3
            // Neon Green to Maroon Gradient (MANX OS High-End Aesthetic)
            active-gradient from="#00FF66" to="#990022" angle=45
            inactive-color "#444444"
        }

        border {
            off
        }
    }

    // ############ STARTUP INITIALIZATION ############
    spawn-at-startup "dbus-update-activation-environment" "--all"
    spawn-at-startup "bash" "-c" "sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    spawn-at-startup "systemctl" "--user" "start" "graphical-session.target"
    spawn-at-startup "systemctl" "--user" "start" "hyprpolkitagent"
    spawn-at-startup "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
    spawn-at-startup "gnome-keyring-daemon" "--start" "--components=secrets"
    spawn-at-startup "bash" "-c" "$HOME/.local/bin/sync_ghostty.sh"
    spawn-at-startup "bash" "-c" "$HOME/.local/bin/manx-shell-load"
    spawn-at-startup "bash" "-c" "sleep 5 && distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/xic/xic"

    // ############ VLSI & EDA TOOL RULES ############

    // Float and Center secondary Vivado windows and popups
    window-rule {
        match app-id=r#"^vivado$"#
        match app-id=r#"^Vivado$"#
        exclude title=r#"^Vivado"# // Do not match main Vivado window
        open-floating true
    }

    // Float Physical Layout Editors
    window-rule {
        match app-id=r#"^magic$"#
        open-floating true
    }
    window-rule {
        match app-id=r#"^klayout$"#
        open-floating true
    }
    window-rule {
        match app-id=r#"^xschem$"#
        open-floating true
    }
    window-rule {
        match app-id=r#"^gtkwave$"#
        open-floating true
    }

    // Float XPPen Tablet settings
    window-rule {
        match app-id=r#"^pentablet$"#
        open-floating true
        default-floating-width 800
        default-floating-height 600
    }

    // Float Polkit Authentication Dialogs
    window-rule {
        match app-id=r#"^hyprpolkitagent$"#
        open-floating true
        default-floating-width 450
        default-floating-height 250
    }

    // Float Screensaver
    window-rule {
        match app-id=r#"^manx-screensaver$"#
        open-floating true
    }

    // Float Audio Control, Bluetooth, and Connection Managers
    window-rule {
        match app-id=r#"^pavucontrol$"#
        match app-id=r#"^org\.pulseaudio\.pavucontrol$"#
        match app-id=r#"^blueberry\.py$"#
        match app-id=r#"^nm-connection-editor$"#
        open-floating true
    }

    // Float Amberol Music Widget
    window-rule {
        match app-id=r#"^amberol$"#
        match app-id=r#"^io\.github\.AlistairMilne\.Amberol$"#
        open-floating true
        default-floating-width 360
        default-floating-height 520
    }

    // Float Spotube Dashboard
    window-rule {
        match app-id=r#"^spotube$"#
        open-floating true
        default-floating-width 950
        default-floating-height 650
    }

    // ############ KEYBINDINGS ############
    binds {
        // Core Mappings (System Launcher / Terminal)
        Mod+Return { spawn "ghostty"; }
        Mod+T { spawn "kitty"; }
        Mod+Shift+T { spawn "ambxst" "run" "tmux"; }
        Mod+Q { close-window; }
        Print { spawn "ambxst" "run" "screenshot"; }
        Mod+L { spawn "loginctl" "lock-session"; }
        
        // System Actions & Toggle Scripts
        Mod+G { spawn "bash" "-c" "$HOME/.local/bin/manx-toggle-grayscale"; }
        Mod+Equal { spawn "bash" "-c" "$HOME/.local/bin/manx-zoom" "in"; }
        Mod+Plus { spawn "bash" "-c" "$HOME/.local/bin/manx-zoom" "in"; }
        Mod+Minus { spawn "bash" "-c" "$HOME/.local/bin/manx-zoom" "out"; }
        Mod+BackSpace { spawn "bash" "-c" "$HOME/.local/bin/manx-zoom" "reset"; }

        // Noctalia Launcher Search Bind
        Mod+D { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "launcher" "toggle"; }

        // Focus Columns/Monitors (Directional navigation)
        Mod+Left  { focus-column-or-monitor-left; }
        Mod+Right { focus-column-or-monitor-right; }
        Mod+Down  { focus-window-or-workspace-down; }
        Mod+Up    { focus-window-or-workspace-up; }

        // Move Windows/Columns (Directional sorting)
        Mod+Shift+Left  { move-column-to-monitor-left; }
        Mod+Shift+Right { move-column-to-monitor-right; }
        Mod+Shift+Down  { move-window-down-or-to-workspace-down; }
        Mod+Shift+Up    { move-window-up-or-to-workspace-up; }

        // Preset column resizing
        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { center-window; }

        // Floating Management
        Mod+Space { toggle-window-floating; }
        Mod+Shift+Space { switch-focus-between-floating-and-tiling; }

        // Workspace index navigation
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Horizontal window width controls (similar to Hyprland resize active)
        Mod+Ctrl+Left  { consume-or-expel-window-left; }
        Mod+Ctrl+Right { consume-or-expel-window-right; }
        
        Mod+Alt+Right { set-column-width "+10%"; }
        Mod+Alt+Left  { set-column-width "-10%"; }
    }
  '';
}
