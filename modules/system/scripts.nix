{ pkgs, vars, ... }:

let
  manx-script = pkgs.writeShellScriptBin "manx" ''
    # Advanced NixOS Management Utility
    # Custom-built for the MANX Engineering Workstation

    set -e # Exit on error

    # --- CONFIGURATION ---
    CONFIG_DIR="$HOME/nix-config"
    export FLAKE="$CONFIG_DIR"
    export NH_FLAKE="$CONFIG_DIR"
    HOSTNAME="MANX"
    HOST_DIR=$(echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]')
    EDITOR="nvim"
    VIVADO_VERSION="${vars.vivadoVersion}"

    # --- COLOR PALETTE (Optimized for Ghostty/Kitty) ---
    C_PRIMARY='\033[38;5;208m'   # Coral Orange
    C_SECONDARY='\033[38;5;99m'  # Royal Soft Purple
    C_HIGHLIGHT='\033[38;5;43m'  # Vibrant Teal
    C_SUCCESS='\033[38;5;76m'    # Emerald Green
    C_MUTED='\033[38;5;244m'     # Dim Grey
    C_WHITE='\033[1;37m'         # Bright White
    C_GOLD='\033[38;5;220m'      # Warm Gold

    # Base UI Colors (Compat for legacy shell functions)
    GREEN='\033[1;32m'
    BLUE='\033[1;34m'
    YELLOW='\033[1;33m'
    RED='\033[1;31m'
    MAGENTA='\033[1;35m'
    CYAN='\033[1;36m'
    NC='\033[0m'

    function log() { echo -e "''${C_SECONDARY}  [SYSTEM]''${NC} $1"; }
    function error() { echo -e "''${RED}󰅚  [ERROR]''${NC} $1"; exit 1; }
    function success() { echo -e "''${C_SUCCESS}󰄬  [SUCCESS]''${NC} $1"; }
    function info() { echo -e "''${C_HIGHLIGHT}󰌢  [INFO]''${NC} $1"; }

    # Help Menu Function
    function show_help() {
        # Calculate uptime reliably
        local uptime_all=$(cat /proc/uptime)
        local uptime_seconds=''${uptime_all%%.*}
        local days=$((uptime_seconds / 86400))
        local hours=$(( (uptime_seconds % 86400) / 3600 ))
        local mins=$(( (uptime_seconds % 3600) / 60 ))
        local uptime_str=""
        if [ ''$days -gt 0 ]; then uptime_str+="''$days""d "; fi
        if [ ''$hours -gt 0 ]; then uptime_str+="''$hours""h "; fi
        uptime_str+="''$mins""m"

        echo -e ""
        echo -e "  ''${C_PRIMARY}󱄅''${NC}  ''${C_WHITE}M A N X   W O R K S T A T I O N''${NC}  ''${C_MUTED}│''${NC}  ''${C_SECONDARY}''${NC}  ''${C_GOLD}NIXOS SYSTEM''${NC}"
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e "  ''${C_HIGHLIGHT}  Host:''${NC} ''${C_WHITE}''$HOSTNAME''${NC}         ''${C_HIGHLIGHT}󰓅  Uptime:''${NC} ''${C_WHITE}''$uptime_str''${NC}"
        echo -e "  ''${C_HIGHLIGHT}  Kernel:''${NC} ''${C_WHITE}''$(uname -r)''${NC}       ''${C_HIGHLIGHT}  Status:''${NC} ''${C_SUCCESS}Online''${NC}"
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e ""
        echo -e "  ''${C_SECONDARY}Usage:''${NC} ''${C_WHITE}manx''${NC} ''${C_GOLD}<command>''${NC}"
        echo -e ""
        echo -e "  ''${C_PRIMARY}󰓅  CONFIGURATION MANAGEMENT''${NC}"
        echo -e "    ''${C_WHITE}rebuild''${NC}   ''${C_MUTED}❯''${NC} Synchronize adjustments and show package changes"
        echo -e "    ''${C_WHITE}update''${NC}    ''${C_MUTED}❯''${NC} Update system inputs and perform full build"
        echo -e "    ''${C_WHITE}rollback''${NC}  ''${C_MUTED}❯''${NC} Revert to previous successful generation"
        echo -e "    ''${C_WHITE}history''${NC}   ''${C_MUTED}❯''${NC} List detailed system generations"
        echo -e ""
        echo -e "  ''${C_PRIMARY}󰌢  MAINTENANCE & SECURITY''${NC}"
        echo -e "    ''${C_WHITE}clean''${NC}     ''${C_MUTED}❯''${NC} Execute deep system maintenance protocols"
        echo -e "    ''${C_WHITE}check''${NC}     ''${C_MUTED}❯''${NC} Validate configuration health and integrity"
        echo -e ""
        echo -e "  ''${C_PRIMARY}  DEVELOPMENT UTILITIES''${NC}"
        echo -e "    ''${C_WHITE}edit''${NC}      ''${C_MUTED}❯''${NC} Open primary system configuration"
        echo -e "    ''${C_WHITE}search''${NC}    ''${C_MUTED}❯''${NC} Query the Nixpkgs software registry"
        echo -e "    ''${C_WHITE}shell''${NC}     ''${C_MUTED}❯''${NC} Initialize isolated package environments"
        echo -e "    ''${C_WHITE}vivado''${NC}    ''${C_MUTED}❯''${NC} Enter the AMD Vivado design environment"
        echo -e ""
        echo -e "  ''${C_PRIMARY}󰪢  BRANDING & AESTHETICS''${NC}"
        echo -e "    ''${C_WHITE}screensaver''${NC} ''${C_MUTED}❯''${NC} Orchestrate immersive workstation branding"
        echo -e ""
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e "  ''${C_HIGHLIGHT}󰌢  Type 'man manx' to access the system documentation.''${NC}"
        echo -e ""
    }

    # Initialize Git tracking if it's missing
    if [ ! -d "$CONFIG_DIR/.git" ]; then
        info "Initializing configuration tracking repository..."
        git init "$CONFIG_DIR" > /dev/null
    fi

    if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        show_help
        exit 0
    fi

    # Jump to the config directory for all operations
    cd "$CONFIG_DIR"

    case $1 in
      rebuild)
        log "Executing system synchronization..."
        
        # 0. Create pre-rebuild Btrfs snapshots for safety
        if command -v snapper &> /dev/null; then
            log "Creating pre-rebuild snapshots (Time Machine)..."
            # Root is excluded because it is stateless and wiped on every boot
            sudo snapper -c home create --description "Pre-rebuild home snapshot" || true
        fi

        # 1. Enforce code style standards (RFC-166) BEFORE staging
        nix fmt
        
        # 2. Stage changes to ensure Nix Flakes see all current work
        git add . &> /dev/null || true
        
        # 3. Validate configuration integrity before applying
        log "Validating configuration health..."
        if ! nix flake check . 2>/tmp/nix-check-err; then
            grep -v -E "incompatible systems|all-systems" /tmp/nix-check-err >&2 || true
            rm -f /tmp/nix-check-err
            error "Configuration audit failed. Please resolve errors before rebuilding."
        else
            grep -v -E "incompatible systems|all-systems" /tmp/nix-check-err >&2 || true
            rm -f /tmp/nix-check-err
        fi
        
        # 4. Capture current system state for delta reporting
        OLD_GEN=$(readlink -f /nix/var/nix/profiles/system)
        
        # 5. Apply system configuration via NH
        log "Applying system updates..."
        nh os switch . --hostname $HOSTNAME -- --accept-flake-config || error "System rebuild failed."
        
        # 6. Generate package change report
        NEW_GEN=$(readlink -f /nix/var/nix/profiles/system)
        echo -e "\n''${C_HIGHLIGHT}  Package Changes:''${NC}"
        nvd diff "$OLD_GEN" "$NEW_GEN"
        
        # 7. Record system state with a diff summary
        if git status --porcelain | grep -q '^[ MADRCU]'; then
            log "Recording system state to Git history..."
            echo -e "\n''${C_MUTED}Change Summary:''${NC}"
            git diff --stat HEAD
            git commit -m "System Update: $(date '+%Y-%m-%d %H:%M')" &> /dev/null || true
        fi

        # 8. Synchronize with remote repository (Optional)
        if git remote | grep -q "origin"; then
            log "Synchronizing configuration with GitHub..."
            if git push origin main; then
                success "GitHub synchronization complete. All changes are backed up!"
            else
                info "GitHub sync skipped (check internet or remote settings)."
            fi
        fi

        success "System configuration applied successfully."
        ;;

      update)
        log "Updating system inputs and dependencies..."
        nh os switch . --update --hostname $HOSTNAME || error "System update failed."
        success "System updated and synchronized."
        ;;

      clean)
        log "Performing deep system maintenance..."
        
        # LAYER 1: Generation Pruning
        log "Pruning legacy generations (Keeping last 3)..."
        nh clean all --keep 3
        
        # LAYER 2: Garbage Collection
        log "Executing garbage collection cycle..."
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        
        # LAYER 3: Store Optimization
        log "Optimizing Nix store (Hard-linking duplicates)..."
        sudo nix-store --optimise
        
        success "System maintenance complete. Storage optimized."
        ;;

      edit)
        # Open the primary system configuration (Dynamically resolved path)
        $EDITOR hosts/$HOST_DIR/configuration.nix
        ;;

      search)
        shift
        log "Querying Nixpkgs registry for: $@"
        nh search "$@"
        ;;

      check)
        log "Auditing configuration health..."
        if ! nix flake check . 2>/tmp/nix-check-err; then
            grep -v -E "incompatible systems|all-systems" /tmp/nix-check-err >&2 || true
            rm -f /tmp/nix-check-err
            error "Configuration audit failed."
        else
            grep -v -E "incompatible systems|all-systems" /tmp/nix-check-err >&2 || true
            rm -f /tmp/nix-check-err
            success "Configuration verified."
        fi
        ;;

      shell)
        shift
        log "Entering shell for: $@"
        nix-shell -p "$@"
        ;;

      history)
        nixos-rebuild list-generations
        ;;

      rollback)
        log "Restoring system to previous successful state..."
        sudo nixos-rebuild switch --flake .#$HOSTNAME --rollback
        ;;

      screensaver)
        BRAND_DIR="$HOME/.config/omarchy/branding"
        mkdir -p "$BRAND_DIR"
        
        shift
        case $1 in
          ascii)
            info "Opening ASCII editor. Save and exit to apply changes."
            $EDITOR "$BRAND_DIR/screensaver.txt"
            # Clean up logo if text is being used
            rm -f "$BRAND_DIR/logo.png" 2>/dev/null || true
            success "ASCII art updated. Launching preview..."
            pkill -f 'alacritty --class manx-screensaver' || true
            "$HOME/.local/bin/manx-screensaver" --force
            ;;
          
          image)
            IMG_PATH="$2"
            if [ -z "$IMG_PATH" ] || [ ! -f "$IMG_PATH" ]; then
                error "Please provide a valid image path. Usage: manx screensaver image <path>"
            fi
            
            log "Processing branding image..."
            cp "$IMG_PATH" "$BRAND_DIR/logo.png"
            # Clean up text if image is being used
            rm -f "$BRAND_DIR/screensaver.txt" 2>/dev/null || true
            
            success "Branding image updated. Launching preview..."
            pkill -f 'alacritty --class manx-screensaver' || true
            "$HOME/.local/bin/manx-screensaver" --force
            ;;
          
          toggle)
            TOGGLE_FILE="$HOME/.local/state/omarchy/toggles/screensaver-off"
            mkdir -p "$(dirname "$TOGGLE_FILE")"
            if [ -f "$TOGGLE_FILE" ]; then
                rm "$TOGGLE_FILE"
                success "Screensaver ENABLED."
            else
                touch "$TOGGLE_FILE"
                info "Screensaver DISABLED."
            fi
            ;;
          
          reset)
            log "Resetting branding to system defaults..."
            rm -rf "$BRAND_DIR"
            success "Screensaver branding reset."
            ;;
            
          *)
            echo -e "  ''${C_SECONDARY}Usage:''${NC} ''${C_WHITE}manx screensaver''${NC} ''${C_GOLD}<action>''${NC}"
            echo -e ""
            echo -e "    ''${C_WHITE}ascii''${NC}   ''${C_MUTED}❯''${NC} Edit your custom ASCII art text"
            echo -e "    ''${C_WHITE}image''${NC}   ''${C_MUTED}❯''${NC} Set an image to be converted to ASCII"
            echo -e "    ''${C_WHITE}toggle''${NC}  ''${C_MUTED}❯''${NC} Master switch for the screensaver"
            echo -e "    ''${C_WHITE}reset''${NC}   ''${C_MUTED}❯''${NC} Restore default MANX Silicon branding"
            echo -e ""
            ;;
        esac
        ;;

      vivado)
        log "Entering AMD Vivado container..."
        
        if ! command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
            error "No container engine found!"
        fi

        if command -v xhost &>/dev/null; then
            xhost +local: &> /dev/null || true
        fi

        if ! distrobox list | grep -q "manx-vivado"; then
            info "Vivado environment not found. Creating it..."
            distrobox create --name manx-vivado --image ubuntu:22.04 --yes || error "Failed to create container."
            success "Environment created! Use 'manx vivado' to install."
        else
            mkdir -p $HOME/.local/share/icons/xilinx
            distrobox enter manx-vivado -- bash -c "
                cp -f /tools/Xilinx/$VIVADO_VERSION/Vivado/doc/images/vivado_logo.png \$HOME/.local/share/icons/xilinx/vivado.png 2>/dev/null || true
                cp -f /tools/Xilinx/ide/electron-app/lnx64/resources/app/resources/icons/vitis-logo-latest.png \$HOME/.local/share/icons/xilinx/vitis.png 2>/dev/null || true
            " &> /dev/null || true

            log "Entering container. Type 'exit' to return."
            export _JAVA_AWT_WM_NONREPARENTING=1
            distrobox enter manx-vivado
        fi
        ;;

      *)
        error "Unknown command: $1. Type 'manx' for help."
        ;;
    esac
  '';

  # Custom Manual Page
  man-page = pkgs.runCommand "manx-man" { } ''
        mkdir -p $out/share/man/man1
        cat <<EOF > $out/share/man/man1/manx.1
    .TH MANX 1 "May 2026" "v1.2" "MANX OS System Manual"
    .SH NAME
    manx \- Advanced NixOS Management Utility
    .SH SYNOPSIS
    .B manx
    [\fIcommand\fR]
    .SH DESCRIPTION
    .B manx
    is a professional management tool for the MANX workstation. It uses NH, NVD, and Deep Clean protocols.
    .SH COMMANDS
    .TP
    .B rebuild
    Applies the configuration with NH and shows a package diff report.
    .TP
    .B update
    Updates all inputs and performs a full rebuild.
    .TP
    .B clean
    A three-layer deep maintenance protocol for storage optimization.
    .TP
    .B check
    Validates config integrity using nix flake check.
    .TP
    .B vivado
    Enters the high-compatibility Vivado container.
    .TP
    .B screensaver
    Manages custom branding (ASCII/Image) and the master toggle for the Omarchy-style screensaver.
    .SH AUTHOR
    MANX Engineering.
    EOF
  '';
in
{
  environment.systemPackages = [
    manx-script
    pkgs.nixfmt
    man-page
  ];

  documentation.man.enable = true;
}
