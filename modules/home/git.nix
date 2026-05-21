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

  # Modern diff viewer for Verilog/VHDL code reviews
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "base16-256"; # Clean terminal theme
    };
  };
}
