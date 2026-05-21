{ config, pkgs, ... }:

{
  # Starship Prompt (Dynamic & Theme-Aware)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$cmd_duration $directory$git_branch\n  $character";
      fill = {
        symbol = "-";
        style = "fg:8";
      };
      character = {
        success_symbol = "[ ](bold fg:4)";
        error_symbol = "[ ](bold fg:1)";
      };
      package.disabled = true;
      git_branch = {
        style = "bg:4";
        symbol = "󰘬";
        truncation_length = 12;
        truncation_symbol = "";
        format = " 󰜥 [](bold fg:4)[$symbol $branch(:$remote_branch)](fg:0 bg:4)[ ](bold fg:4)";
      };
      git_status.staged = "[++\\($count\\)](green)";
      hostname = {
        ssh_only = false;
        format = "[•$hostname](bg:4 bold fg:0)[](bold fg:4)";
        disabled = false;
      };
      username = {
        style_user = "bold bg:4 fg:0";
        style_root = "red bold";
        format = "[](bold fg:4)[$user]($style)";
        disabled = false;
        show_always = true;
      };
      directory = {
        home_symbol = " ";
        read_only = "  ";
        style = "bg:4 fg:0";
        truncation_length = 2;
        truncation_symbol = ".../";
        format = "[](bold fg:4)[󰉋 → $path]($style)[](bold fg:4)";
      };
      cmd_duration = {
        min_time = 0;
        format = "[](bold fg:4)[󰪢 $duration](bold bg:4 fg:0)[](bold fg:4)";
      };
    };
  };
}
