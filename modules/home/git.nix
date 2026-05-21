{ config, pkgs, vars, ... }:

{
  # Professional Git Configuration
  programs.git = {
    enable = true;
    userName = vars.fullName;
    userEmail = vars.email;

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "nvim";
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit";
      ps = "push";
      pl = "pull";
      lg = "log --oneline --graph --decorate";
    };
  };
}
