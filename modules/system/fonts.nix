{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # --- Coding & Terminal Fonts ---
      nerd-fonts.jetbrains-mono
      nerd-fonts.zed-mono
      nerd-fonts.fira-code
      nerd-fonts.mononoki

      # --- Professional & Document Fonts ---
      corefonts # Arial, Times New Roman, etc.
      liberation_ttf # Open source metric-compatible MS fonts
      noto-fonts # High quality multi-language support
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      roboto # Clean modern font
      league-gothic # Heading font

      # --- Future Font Support Base ---
      dejavu_fonts
      google-fonts # Huge collection of open source fonts
    ];

    # Default font settings for a professional look
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Times New Roman" "Noto Serif" ];
        sansSerif = [ "Arial" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "ZedMono Nerd Font" ];
      };
    };
  };
}
