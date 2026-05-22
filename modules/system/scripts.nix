{ pkgs, ... }:

let
  mayank-script = pkgs.writeShellScriptBin "mayank" ''
    # Advanced NixOS Management Utility
    # Custom-built for Mayank Anand's MANX Workstation

    set -e # Exit on error

    # --- CONFIGURATION ---
    CONFIG_DIR="$HOME/nix-config"
    HOSTNAME="MANX"
    EDITOR="nvim"

    # --- PREMIUM UI PALETTE (Optimized for Ghostty/Kitty) ---
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
        echo -e "  ''${C_PRIMARY}󱄅''${NC}  ''${C_WHITE}M A Y A N K   A N A N D''${NC}  ''${C_MUTED}│''${NC}  ''${C_SECONDARY}''${NC}  ''${C_GOLD}NIXOS WORKSTATION''${NC}"
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e "  ''${C_HIGHLIGHT}  Host:''${NC} ''${C_WHITE}''$HOSTNAME''${NC}         ''${C_HIGHLIGHT}󰓅  Uptime:''${NC} ''${C_WHITE}''$uptime_str''${NC}"
        echo -e "  ''${C_HIGHLIGHT}  Kernel:''${NC} ''${C_WHITE}''$(uname -r)''${NC}       ''${C_HIGHLIGHT}  Status:''${NC} ''${C_SUCCESS}Online''${NC}"
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e ""
        echo -e "  ''${C_SECONDARY}Usage:''${NC} ''${C_WHITE}mayank''${NC} ''${C_GOLD}<command>''${NC}"
        echo -e ""
        echo -e "  ''${C_PRIMARY}󰓅  CONFIGURATION MANAGEMENT''${NC}"
        echo -e "    ''${C_WHITE}rebuild''${NC}   ''${C_MUTED}❯''${NC} Apply adjustments & show package changes"
        echo -e "    ''${C_WHITE}update''${NC}    ''${C_MUTED}❯''${NC} Update all inputs and perform full build"
        echo -e "    ''${C_WHITE}rollback''${NC}  ''${C_MUTED}❯''${NC} Instantly revert to previous generation"
        echo -e "    ''${C_WHITE}history''${NC}   ''${C_MUTED}❯''${NC} List all system generations"
        echo -e ""
        echo -e "  ''${C_PRIMARY}󰌢  MAINTENANCE & SECURITY''${NC}"
        echo -e "    ''${C_WHITE}clean''${NC}     ''${C_MUTED}❯''${NC} Deep three-layer store optimization"
        echo -e "    ''${C_WHITE}check''${NC}     ''${C_MUTED}❯''${NC} Audit system health and config integrity"
        echo -e ""
        echo -e "  ''${C_PRIMARY}  DEVELOPMENT UTILITIES''${NC}"
        echo -e "    ''${C_WHITE}edit''${NC}      ''${C_MUTED}❯''${NC} Open workstation config in Neovim"
        echo -e "    ''${C_WHITE}search''${NC}    ''${C_MUTED}❯''${NC} Query the Nixpkgs registry"
        echo -e "    ''${C_WHITE}shell''${NC}     ''${C_MUTED}❯''${NC} Open ephemeral package shells"
        echo -e "    ''${C_WHITE}vivado''${NC}    ''${C_MUTED}❯''${NC} Enter the AMD Vivado container"
        echo -e ""
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e "  ''${C_HIGHLIGHT}󰌢  Type 'man mayank' to see the custom system manual page.''${NC}"
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
        log "Starting Premium system rebuild..."
        
        # Format code
        nix fmt
        
        # Git Tracking
        git add . &> /dev/null || true
        
        # Capture old generation for the diff
        OLD_GEN=$(readlink /nix/var/nix/profiles/system)
        
        # Run rebuild with NH and progress monitor
        nh os switch . --hostname $HOSTNAME -- --accept-flake-config || error "Rebuild failed."
        
        # Show what packages changed
        NEW_GEN=$(readlink /nix/var/nix/profiles/system)
        echo -e "\n''${C_HIGHLIGHT}  Package Changes:''${NC}"
        nvd diff "$OLD_GEN" "$NEW_GEN"
        
        # Push to GitHub if origin exists
        if git remote | grep -q "origin"; then
            log "Syncing with GitHub..."
            git commit -m "System Update: $(date '+%Y-%m-%d %H:%M')" &> /dev/null || true
            git push origin main &> /dev/null || info "Push skipped (check remote)"
        fi

        success "System applied successfully!"
        ;;

      update)
        log "Updating all inputs and building..."
        nh os switch . --update --hostname $HOSTNAME || error "Update failed."
        success "System updated!"
        ;;

      clean)
        log "Starting Three-Layer Deep Clean..."
        
        # 1. Clean old generations
        log "Cleaning old generations (Keeping last 3)..."
        nh clean all --keep 3
        
        # 2. Deep Garbage Collection
        log "Purging unused store objects..."
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        
        # 3. Store Optimization
        log "Optimizing store (Hard-linking)..."
        sudo nix-store --optimise
        
        success "Deep cleanup complete! Your storage is 100% optimized."
        ;;

      edit)
        $EDITOR hosts/$HOSTNAME/configuration.nix
        ;;

      search)
        shift
        log "Searching for: $@"
        nix-env -qaP "$@"
        ;;

      check)
        log "Checking config health..."
        nom flake check . --all-systems || error "Integrity check failed."
        success "Config is stable!"
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
        log "Rolling back to previous state..."
        sudo nixos-rebuild switch --flake .#$HOSTNAME --rollback
        ;;

      vivado)
        log "Entering AMD Vivado container..."
        
        if ! command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
            error "No container engine found!"
        fi

        if command -v xhost &> /dev/null; then
            xhost +local: &> /dev/null || true
        fi

        if ! distrobox list | grep -q "mayank-vivado"; then
            info "Vivado environment not found. Creating it..."
            distrobox create --name mayank-vivado --image ubuntu:22.04 --yes || error "Failed to create container."
            success "Environment created! Use 'mayank vivado' to install."
        else
            mkdir -p $HOME/.local/share/icons/xilinx
            distrobox enter mayank-vivado -- bash -c "
                cp -f /tools/Xilinx/2025.2/Vivado/doc/images/vivado_logo.png \$HOME/.local/share/icons/xilinx/vivado.png 2>/dev/null || true
                cp -f /tools/Xilinx/ide/electron-app/lnx64/resources/app/resources/icons/vitis-logo-latest.png \$HOME/.local/share/icons/xilinx/vitis.png 2>/dev/null || true
            " &> /dev/null || true

            log "Entering container. Type 'exit' to return."
            export _JAVA_AWT_WM_NONREPARENTING=1
            distrobox enter mayank-vivado
        fi
        ;;

      *)
        error "Unknown command: $1. Type 'mayank' for help."
        ;;
    esac
  '';

  # Custom Manual Page
  man-page = pkgs.runCommand "mayank-man" { } ''
        mkdir -p $out/share/man/man1
        cat <<EOF > $out/share/man/man1/mayank.1
    .TH MAYANK 1 "May 2026" "v1.1" "MANX OS System Manual"
    .SH NAME
    mayank \- Advanced NixOS Management for Mayank Anand
    .SH SYNOPSIS
    .B mayank
    [\fIcommand\fR]
    .SH DESCRIPTION
    .B mayank
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
    Validates config integrity with nix-output-monitor.
    .TP
    .B vivado
    Enters the high-compatibility Vivado container.
    .SH AUTHOR
    Mayank Anand.
    EOF
  '';
in
{
  environment.systemPackages = [
    mayank-script
    pkgs.nixfmt
    man-page
  ];

  documentation.man.enable = true;
}
