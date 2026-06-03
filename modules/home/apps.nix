{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # --- Daily Use & Fun Apps ---
    cowsay
    figlet
    toilet
    screenfetch
    cpufetch
    onefetch # Git repo info
    fortune # Random quotes
    pipes # Terminal pipes screensaver
    cbonsai # Terminal bonsai tree
    sl # Steam Locomotive (runs when ls is mistyped)

    # --- Utilities ---
    zip
    unzip
    p7zip
    ripgrep # Fast searching
    fd # Fast finding
    jq # JSON processor
    # --- File Manager ---
    nautilus
    nautilus-python
    sushi
    # --- AI ---
    kiro-fhs
    cursor-cli
    code-cursor-fhs
    warp-terminal
    windsurf
    codex
    codex-acp
    fabric-ai # Advanced modular AI framework for daily tasks
    shell-gpt # Command-line productivity tool powered by AI
  ];
}
