{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Extra Packages for Images & PDFs
    extraPackages = with pkgs; [
      imagemagick
      ueberzugpp
      poppler-utils # FIXED: renamed from poppler_utils
      ghostscript
    ];

    # =========================================================================
    # DYNAMIC THEME SYNC & NEOVIDE SUPPORT
    # =========================================================================
    colorschemes.base16 = {
      enable = true;
      scheme = "catppuccin-mocha";
    };

    plugins.web-devicons.enable = true;

    # =========================================================================
    # ELITE DASHBOARD
    # =========================================================================
    plugins.dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        config = {
          header = [
            " "
            "███╗   ███╗ █████╗ ██╗   ██╗ █████╗ ███╗   ██╗██╗  ██╗"
            "████╗ ████║██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║██║ ██╔╝"
            "██╔████╔██║███████║ ╚████╔╝ ███████║██╔██╗ ██║█████╔╝ "
            "██║╚██╔╝██║██╔══██║  ╚██╔╝  ██╔══██║██║╚██╗██║██╔═██╗ "
            "██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██║ ╚████║██║  ██╗"
            "╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝"
            " "
            "      █████╗ ███╗   ██╗ █████╗ ███╗   ██╗██████╗ "
            "     ██╔══██╗████╗  ██║██╔══██╗████╗  ██║██╔══██╗"
            "     ███████║██╔██╗ ██║███████║██╔██╗ ██║██║  ██║"
            "     ██╔══██║██║╚██╗██║██╔══██║██║╚██╗██║██║  ██║"
            "     ██║  ██║██║ ╚████║██║  ██║██║ ╚████║██████╔╝"
            "     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ "
            " "
            "          P R O F E S S I O N A L   V L S I   I D E"
            " "
          ];
          center = [
            { action = "Telescope find_files"; desc = " Find File"; icon = " "; key = "f"; }
            { action = "Telescope oldfiles"; desc = " Recent Files"; icon = " "; key = "r"; }
            { action = "Telescope live_grep"; desc = " Find Text"; icon = " "; key = "g"; }
            { action = "e $HOME/nix-config/modules/home/nixvim.nix"; desc = " Config"; icon = " "; key = "c"; }
            { action = "qa"; desc = " Quit"; icon = " "; key = "q"; }
          ];
          footer = [ "Mayank Anand's God Mode Workstation" ];
        };
      };
    };

    # =========================================================================
    # IMAGE & MEDIA SUPPORT
    # =========================================================================
    plugins.image = {
      enable = true;
      backend = "ueberzug";
      integrations.markdown.enabled = true;
    };

    # Telescope Extension for Media Previews
    plugins.telescope = {
      enable = true;
      extensions.media-files = {
        enable = true;
        # FIXED: Removed 'dependencies' wrapper as per rename warning
        settings = {
          chafa = true;
          ffmpegthumbnailer = true;
          imagemagick = true;
          pdftotext = true;
        };
      };
    };

    # =========================================================================
    # PROFESSIONAL VLSI LSPs & TOOLS
    # =========================================================================
    plugins.lsp = {
      enable = true;
      servers = {
        verible.enable = true; # SystemVerilog
        vhdl_ls.enable = true; # VHDL
        clangd.enable = true; # SystemC / C++
        asm_lsp.enable = true; # Assembly
        pyright.enable = true; # Python
        nil_ls.enable = true; # Nix
        lua_ls.enable = true; # Lua
      };
      keymaps.lspBuf = {
        gd = "definition";
        gr = "references";
        K = "hover";
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
      };
    };

    # Formatting (Conform)
    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_fallback = true;
          timeout_ms = 500;
        };
      };
    };

    # Syntax Highlighting
    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        systemverilog
        vhdl
        bash
        c
        cpp
        lua
        make
        markdown
        nix
        python
        vim
        vimdoc
      ];
    };

    # Code Outline
    plugins.aerial = {
      enable = true;
      settings = {
        layout = {
          max_width = [ 40 0.2 ];
          min_width = 10;
        };
      };
    };

    # =========================================================================
    # ADVANCED UI & EXPERIENCE
    # =========================================================================
    plugins = {
      lualine = { enable = true; settings.options.theme = "auto"; };
      bufferline.enable = true;
      neo-tree.enable = true;
      which-key.enable = true;
      noice.enable = true;
      notify.enable = true;
      indent-blankline.enable = true;
      gitsigns.enable = true;
      todo-comments.enable = true;
      trouble.enable = true;
      lazygit.enable = true;
      persistence.enable = true;

      # Autocompletion
      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          sources = [{ name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; }];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
        };
      };

      # Professional Terminal
      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<C-\\>]]";
          direction = "float";
          shade_terminals = false;
          float_opts = { border = "curved"; winblend = 0; };
        };
      };

      autopairs.enable = true;
      comment.enable = true;
    };

    # =========================================================================
    # KEYMAPS & CUSTOM LOGIC
    # =========================================================================
    globals.mapleader = " ";
    keymaps = [
      { mode = "n"; key = "<C-n>"; action = ":Neotree toggle<CR>"; }
      { mode = "n"; key = "<leader>e"; action = ":Neotree focus<CR>"; }
      { mode = "n"; key = "<leader>ff"; action = ":Telescope find_files<CR>"; }
      { mode = "n"; key = "<leader>fg"; action = ":Telescope live_grep<CR>"; }
      { mode = "n"; key = "<leader>h"; action = ":nohlsearch<CR>"; }

      # Media Preview Keybind
      { mode = "n"; key = "<leader>fm"; action = ":Telescope media_files<CR>"; options.desc = "Find Media Files"; }

      # VLSI & UI Keybinds
      { mode = "n"; key = "<leader>o"; action = ":AerialToggle<CR>"; options.desc = "Code Outline"; }
      { mode = "n"; key = "<leader>gg"; action = ":LazyGit<CR>"; options.desc = "LazyGit"; }
      { mode = "n"; key = "<leader>qs"; action = ":lua require('persistence').load()<CR>"; options.desc = "Restore Session"; }

      # Terminal Keybinds
      { mode = "n"; key = "<leader>tf"; action = ":ToggleTerm direction=float<CR>"; }
      { mode = "n"; key = "<leader>th"; action = ":ToggleTerm size=15 direction=horizontal<CR>"; }
      { mode = "n"; key = "<leader>tv"; action = ":ToggleTerm size=60 direction=vertical<CR>"; }

      # Tabs
      { mode = "n"; key = "<S-l>"; action = ":bnext<CR>"; }
      { mode = "n"; key = "<S-h>"; action = ":bprev<CR>"; }
      { mode = "n"; key = "<leader>x"; action = ":bdelete<CR>"; }
    ];

    extraConfigLua = ''
      -- 1. FORCE DYNAMIC TRANSPARENCY
      local function apply_transparency()
        local groups = { "Normal", "NormalFloat", "FloatBorder", "LineNr", "CursorLineNr", "NeoTreeNormal", "NeoTreeNormalNC" }
        for _, group in ipairs(groups) do
          vim.api.nvim_set_hl(0, group, { bg = "none" })
        end
      end
      apply_transparency()

      -- 2. DYNAMIC THEME ADAPTATION
      vim.o.termguicolors = true
      
      -- 3. NEOVIDE SUPPORT
      if vim.g.neovide then
        vim.g.neovide_transparency = 0.95
        vim.o.guifont = "JetBrains Mono Nerd Font:h14"
      end

      -- 4. VLSI FILE DETECTION
      vim.filetype.add({
        extension = {
          sc = "cpp",
          v = "verilog",
          sv = "systemverilog",
        },
      })
    '';
  };
}
