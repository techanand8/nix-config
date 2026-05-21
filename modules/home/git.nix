{ config, pkgs, vars, ... }:

{
  # Professional Git Configuration (Modern Schema)
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = vars.fullName;
        email = vars.email;
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "nvim";

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit";
        ps = "push";
        pl = "pull";
        lg = "log --oneline --graph --decorate";
      };
    };
  };
}
