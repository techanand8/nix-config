{
  config,
  pkgs,
  vars,
  ...
}:

{
  # Basic programs
  programs.bash = {
    enable = true;
    shellAliases = {
      sr = "steam-run";
      ar = "appimage-run";
      backup-ece = "hf upload mayank-anand/backup_tools /home/mayank-anand/ece_tools/ece_tools_backup.tar.gz --repo-type=dataset";
      restore-ece = "hf download mayank-anand/backup_tools ece_tools_backup.tar.gz --local-dir /home/mayank-anand/ece_tools --repo-type=dataset";
    };
    initExtra = ''
      # Load Gemini API Key automatically
      if [ -f "$HOME/.config/manx/gemini_token" ]; then
          export GOOGLE_API_KEY=$(cat "$HOME/.config/manx/gemini_token")
          export GEMINI_API_KEY="$GOOGLE_API_KEY"
      fi

      # High-performance Hugging Face Quick-Uploader Helper
      function hf-push() {
        if [[ "$#" -lt 2 ]]; then
          echo -e "\033[1;31m󰅚  [ERROR] Missing arguments!\033[0m"
          echo -e "Usage: \033[1;36mhf-push <repo_id> <local_path_to_file_or_folder> [repo_type]\033[0m"
          echo -e "Example: \033[1;32mhf-push mayank-anand/my-dataset ./my_folder\033[0m"
          return 1
        fi
        local repo_id="$1"
        local local_path="$2"
        local repo_type="dataset"
        if [[ -n "$3" ]]; then
          repo_type="$3"
        fi

        echo -e "\033[1;34m󰗪  [Hugging Face Upload] Starting upload of '$local_path' to '$repo_id' ($repo_type)...\033[0m"
        hf upload "$repo_id" "$local_path" --repo-type="$repo_type"
      }
    '';
  };
  programs.fish.enable = true;
  programs.home-manager.enable = true;

  # Direnv: The Pro way to handle development shells
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # Ensure user local binaries and Cargo binaries are in the PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  # Global Environment Variables
  home.sessionVariables = {
    FLAKE = "${config.home.homeDirectory}/nix-config";
    NH_FLAKE = "${config.home.homeDirectory}/nix-config";
  };

  # Zsh Shell Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "extract"
        "rust"
      ];
      theme = "robbyrussell"; # Starship will override this anyway
    };

    # Smart completion and CD functions
    initContent = ''
      # Load Gemini API Key automatically
      if [ -f "$HOME/.config/manx/gemini_token" ]; then
          export GOOGLE_API_KEY=$(cat "$HOME/.config/manx/gemini_token")
          export GEMINI_API_KEY="$GOOGLE_API_KEY"
      fi

      # Dynamically inject local bin and Cargo bin into shell path
      export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

      # Dynamically load Nix-LD library path to run unpatched pipx/python/binary executables immediately
      export NIX_LD_LIBRARY_PATH="/run/current-system/sw/share/nix-ld/lib"

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.zsh

      # Enhanced cd function with automatic directory listing and zoxide fallback
      function cd() {
        if [[ "$#" -eq 0 ]]; then
          builtin cd ~ && pwd
        elif [[ -d "$1" ]]; then
          builtin cd "$1" && ls
        else
          __zoxide_z "$@" && pwd && ls
        fi
      }

      # Distrobox Safety Guard (Prevents accidental deletion of the Vivado container)
      function distrobox() {
        if [[ "$1" == "rm" && "$*" == *"manx-vivado"* ]]; then
          echo -e "\033[1;31m󰅚  [CRITICAL WARNING] You are attempting to delete 'manx-vivado'!\033[0m"
          echo -e "\033[1;33m󰌢  Deleting this container will wipe out your entire Vivado installation files.\033[0m"
          echo -n "Are you absolutely sure? (Type 'YES-DELETE-VIVADO' to confirm): "
          read confirm
          if [[ "$confirm" != "YES-DELETE-VIVADO" ]]; then
            echo -e "\033[1;32m󰄬  Deletion aborted. Your Vivado container is completely safe!\033[0m"
            return 1
          fi
        fi
        command distrobox "$@"
      }

      # High-performance Xilinx Distrobox Executer Helper
      function vrun() {
        distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 "$@"
      }

      # High-performance Hugging Face Quick-Uploader Helper
      function hf-push() {
        if [[ "$#" -lt 2 ]]; then
          echo -e "\033[1;31m󰅚  [ERROR] Missing arguments!\033[0m"
          echo -e "Usage: \033[1;36mhf-push <repo_id> <local_path_to_file_or_folder> [repo_type]\033[0m"
          echo -e "Example: \033[1;32mhf-push mayank-anand/my-dataset ./my_folder\033[0m"
          return 1
        fi
        local repo_id="$1"
        local local_path="$2"
        local repo_type="dataset"
        if [[ -n "$3" ]]; then
          repo_type="$3"
        fi

        echo -e "\033[1;34m󰗪  [Hugging Face Upload] Starting upload of '$local_path' to '$repo_id' ($repo_type)...\033[0m"
        hf upload "$repo_id" "$local_path" --repo-type="$repo_type"
      }
    '';

    shellAliases = {
      sr = "steam-run";
      ar = "appimage-run";
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ls = "eza --icons --long --header --git --group-directories-first";
      la = "eza --icons --all --long --header --git --group-directories-first";
      tree = "eza --tree --icons";
      cat = "bat";
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      m = "manx";
      mayank = "manx";
      v = "nvim";
      gv = "gvim";
      word = "onlyoffice-desktopeditors";
      grep = "rg";
      anipy-cli = "LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib anipy-cli";

      # --- SECURE VPN COMMANDS ---
      "vpn-up" = "nmcli connection up MavenSilicon";
      "vpn-down" = "nmcli connection down MavenSilicon";
      "vpn-status" = "nmcli connection show --active | grep MavenSilicon";

      # --- AMD Vivado & Tcl Shell Wrappers ---
      vivado = "vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado";
      vivado-tcl = "vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado -mode tcl";

      # GUI Mode in specific terminals
      vivado-ghostty = "ghostty -e vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado";
      vivado-kitty = "kitty -e vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado";
      vivado-xterm = "xterm -e vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado";

      # Interactive Tcl Shell in specific terminals
      vivado-tcl-ghostty = "ghostty -e vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado -mode tcl";
      vivado-tcl-kitty = "kitty -e vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado -mode tcl";
      vivado-tcl-xterm = "xterm -e vrun /tools/Xilinx/${vars.vivadoVersion}/Vivado/bin/vivado -mode tcl";

      # --- Vitis, DocNav, XIC & Uninstaller ---
      vitis = "vrun /tools/Xilinx/${vars.vivadoVersion}/Vitis/bin/vitis";
      vitis-cli = "vrun /tools/Xilinx/${vars.vivadoVersion}/Vitis/bin/vitis -mode cli";
      docnav = "vrun /tools/Xilinx/DocNav/docnav";
      xic = "vrun /tools/Xilinx/xic/xic";
      xuninstall = "vrun /tools/Xilinx/.xinstall/${vars.vivadoVersion}/xsetup -uninstall";

      # --- XP-Pen Tablet Driver Wrappers ---
      xppen = "env QT_QPA_PLATFORM=xcb pentablet";
      pentablet = "env QT_QPA_PLATFORM=xcb pentablet";

      # --- ECE Tools Backup Helper ---
      backup-ece = "hf upload mayank-anand/backup_tools /home/mayank-anand/ece_tools/ece_tools_backup.tar.gz --repo-type=dataset";
      restore-ece = "hf download mayank-anand/backup_tools ece_tools_backup.tar.gz --local-dir /home/mayank-anand/ece_tools --repo-type=dataset";
    };
  };

  # Zoxide (Smart Navigation)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Nix-Index: The "Missing Library" & "Command-not-found" solution
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
