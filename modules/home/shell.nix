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

  # Zsh Configuration (The Professional Pro Environment)
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

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.zsh
      
      # Pro CD function with auto-ls and zoxide fallback
      function cd() {
        if [[ "$#" -eq 0 ]]; then
          builtin cd ~ && pwd
        elif [[ -d "$1" ]]; then
          builtin cd "$1" && ls
        else
          __zoxide_z "$@" && pwd && ls
        fi
      }
    '';

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
    };
  };

  # Zoxide (Smart Navigation)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
