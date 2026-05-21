{ config, pkgs, ... }:

{
  # Enable Yazi integration with professional VLSI-level settings
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    # Core Settings for high-performance navigation
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
      };

      opener = {
        # Professional Editor
        edit = [
          { run = ''nvim "$@"''; block = true; for = "unix"; desc = "Open in Neovim"; }
        ];

        # VLSI Tools
        wave = [
          { run = ''gtkwave "$@"''; detach = true; for = "unix"; desc = "View Waveform"; }
        ];
        layout = [
          { run = ''klayout "$@"''; detach = true; for = "unix"; desc = "Open GDSII Layout"; }
        ];

        # Document Viewer (Nautilus/Sushi fallback)
        doc = [
          { run = ''xdg-open "$@"''; detach = true; for = "unix"; desc = "Open Document"; }
        ];
      };

      open = {
        rules = [
          # Code & Configs
          { name = "*.txt"; use = "edit"; }
          { name = "*.lua"; use = "edit"; }
          { name = "*.nix"; use = "edit"; }
          { name = "*.json"; use = "edit"; }
          { name = "*.v"; use = "edit"; } # Verilog
          { name = "*.sv"; use = "edit"; } # SystemVerilog
          { name = "*.vhdl"; use = "edit"; } # VHDL
          { name = "*.py"; use = "edit"; } # Python scripts

          # VLSI Waveforms
          { name = "*.vcd"; use = "wave"; }
          { name = "*.ghw"; use = "wave"; }
          { name = "*.gtkw"; use = "wave"; }

          # VLSI Layouts
          { name = "*.gds"; use = "layout"; }
          { name = "*.oas"; use = "layout"; }

          # Documentation
          { name = "*.pdf"; use = "doc"; }

          # Fallback
          { mime = "text/*"; use = "edit"; }
        ];
      };
    };
  };
}
