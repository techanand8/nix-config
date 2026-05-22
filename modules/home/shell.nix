{ config, pkgs, vars, ... }:

{
  # Basic programs
  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.home-manager.enable = true;

  # Ensure user local binaries and Cargo binaries are in the PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  # Zsh Shell Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "extract" "rust" ];
      theme = "robbyrussell"; # Starship will override this anyway
    };

    # Smart completion and CD functions
    initContent = ''
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
        if [[ "$1" == "rm" && "$*" == *"mayank-vivado"* ]]; then
          echo -e "\033[1;31m󰅚  [CRITICAL WARNING] You are attempting to delete 'mayank-vivado'!\033[0m"
          echo -e "\033[1;33m󰌢  Deleting this container will wipe out your entire Vivado installation files.\033[0m"
          echo -n "Are you absolutely sure? (Type 'YES-DELETE-VIVADO' to confirm): "
          read confirm
          if [[ "$confirm" != "YES-DELETE-VIVADO" ]]; then
            echo -e "\033[1;32m󰄬  Deletion aborted. Your Vivado container is completely safe!\033[0m"
            return 1
          fi
        fi
        command distrobox "$@"
      }    '';

    shellAliases = {
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
      m = "mayank";
      v = "nvim";
      gv = "gvim";
      grep = "ripgrep";
      anipy-cli = "LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib anipy-cli";

      # --- AMD Vivado & Tcl Shell Wrappers ---
      vivado = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado";
      vivado-tcl = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado -mode tcl";

      # GUI Mode in specific terminals
      vivado-ghostty = "ghostty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado";
      vivado-kitty = "kitty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado";
      vivado-xterm = "xterm -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado";

      # Interactive Tcl Shell in specific terminals
      vivado-tcl-ghostty = "ghostty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado -mode tcl";
      vivado-tcl-kitty = "kitty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado -mode tcl";
      vivado-tcl-xterm = "xterm -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vivado/bin/vivado -mode tcl";

      # --- Vitis, DocNav, XIC & Uninstaller ---
      vitis = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vitis/bin/vitis";
      vitis-cli = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/2025.2/Vitis/bin/vitis -mode cli";
      docnav = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/DocNav/docnav";
      xic = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/xic/xic";
      xuninstall = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/.xinstall/2025.2/xsetup -uninstall";

      # --- XP-Pen Tablet Driver Wrappers ---
      xppen = "env QT_QPA_PLATFORM=xcb pentablet";
      pentablet = "env QT_QPA_PLATFORM=xcb pentablet";
    };
  };

  # Zoxide (Smart Navigation)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
