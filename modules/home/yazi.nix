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
          {
            run = ''nvim "$@"'';
            block = true;
            for = "unix";
            desc = "Open in Neovim";
          }
        ];

        # VLSI Tools
        wave = [
          {
            run = ''gtkwave "$@"'';
            detach = true;
            for = "unix";
            desc = "View Waveform";
          }
        ];
        layout = [
          {
            run = ''klayout "$@"'';
            detach = true;
            for = "unix";
            desc = "Open GDSII Layout";
          }
        ];

        # Document Viewer (Nautilus/Sushi fallback)
        doc = [
          {
            run = ''xdg-open "$@"'';
            detach = true;
            for = "unix";
            desc = "Open Document";
          }
        ];
      };

      open = {
        rules = [
          # Code & Configs
          {
            url = "*.txt";
            use = "edit";
          }
          {
            url = "*.lua";
            use = "edit";
          }
          {
            url = "*.nix";
            use = "edit";
          }
          {
            url = "*.json";
            use = "edit";
          }
          {
            url = "*.v";
            use = "edit";
          } # Verilog
          {
            url = "*.sv";
            use = "edit";
          } # SystemVerilog
          {
            url = "*.vhdl";
            use = "edit";
          } # VHDL
          {
            url = "*.py";
            use = "edit";
          } # Python scripts

          # VLSI Waveforms
          {
            url = "*.vcd";
            use = "wave";
          }
          {
            url = "*.ghw";
            use = "wave";
          }
          {
            url = "*.gtkw";
            use = "wave";
          }

          # VLSI Layouts
          {
            url = "*.gds";
            use = "layout";
          }
          {
            url = "*.oas";
            use = "layout";
          }

          # Documentation
          {
            url = "*.pdf";
            use = "doc";
          }

          # Fallback
          {
            mime = "text/*";
            use = "edit";
          }
        ];
      };
    };
  };
}
