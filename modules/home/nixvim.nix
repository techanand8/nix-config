{
  config,
  pkgs,
  vars,
  ...
}:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Extra Packages for Media & System integration
    extraPackages = with pkgs; [
      imagemagick
      ueberzugpp
      poppler-utils
      ghostscript
      chafa
      ffmpegthumbnailer
      nixfmt
    ];

    # =========================================================================
    # DYNAMIC THEME ENGINE (Ambxst Synchronized)
    # =========================================================================
    # We use Catppuccin as a fallback/base, but the logic in extraConfigLua
    # will override it with the active Ambxst system colors dynamically.
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
        show_end_of_buffer = false;
        integrations = {
          alpha = true;
          cmp = true;
          dashboard = true;
          gitsigns = true;
          illuminate = true;
          indent_blankline.enabled = true;
          lsp_saga = true;
          navic.enabled = true;
          noice = true;
          notify = true;
          neotree = true;
          semantic_tokens = true;
          telescope.enabled = true;
          treesitter = true;
          which_key = true;
        };
      };
    };

    plugins.web-devicons.enable = true;

    # =========================================================================
    # PROFESSIONAL DASHBOARD
    # =========================================================================
    plugins.dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        config = {
          header = [
            " "
            "  ▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜"
            "  ▌            󱄅   M A N X   S Y S T E M             ▐"
            "  ▌               N E O V I M   E N G I N E         ▐"
            "  ▌                                                  ▐"
            "  ▌   ███╗   ███╗  █████╗  ███╗   ██╗ ██╗  ██╗       ▐"
            "  ▌   ████╗ ████║ ██╔══██╗ ████╗  ██║ ╚██╗██╔╝       ▐"
            "  ▌   ██╔████╔██║ ███████║ ██╔██╗ ██║  ╚███╔╝        ▐"
            "  ▌   ██║╚██╔╝██║ ██╔══██║ ██║╚██╗██║  ██╔██╗        ▐"
            "  ▌   ██║ ╚═╝ ██║ ██║  ██║ ██║ ╚████║ ██╔╝ ██╗       ▐"
            "  ▌   ╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚═╝  ╚═╝       ▐"
            "  ▌                                                  ▐"
            "  ▌           P R E C I S I O N   L O G I C         ▐"
            "  ▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟"
            " "
          ];
          center = [
            {
              action = "Telescope find_files";
              desc = " Find File";
              icon = " ";
              key = "f";
            }
            {
              action = "Telescope oldfiles";
              desc = " Recent Files";
              icon = " ";
              key = "r";
            }
            {
              action = "Telescope live_grep";
              desc = " Find Text";
              icon = " ";
              key = "g";
            }
            {
              action = "e /home/${vars.username}/nix-config/modules/home/nixvim.nix";
              desc = " Config";
              icon = " ";
              key = "c";
            }
            {
              action = "qa";
              desc = " Quit";
              icon = " ";
              key = "q";
            }
          ];
          footer = [ "Engineered with Precision by ${vars.fullName}" ];
        };
      };
    };

    # =========================================================================
    # MULTIMEDIA & MEDIA SUPPORT
    # =========================================================================
    plugins.image = {
      enable = true;
      backend = "kitty";
      integrations.markdown.enabled = true;
    };

    plugins.telescope = {
      enable = true;
      settings = {
        defaults = {
          file_ignore_patterns = [
            "^.git/"
            "^node_modules/"
          ];
        };
      };
      extensions.media-files = {
        enable = true;
        settings = {
          chafa = true;
          ffmpegthumbnailer = true;
          imagemagick = true;
          pdftotext = true;
        };
      };
    };

    # =========================================================================
    # ENGINEERING LSPs (VLSI focus)
    # =========================================================================
    plugins.lsp = {
      enable = true;
      servers = {
        verible.enable = true;
        svls.enable = true;
        vhdl_ls.enable = true;
        clangd.enable = true;
        asm_lsp.enable = true;
        nixd = {
          enable = true;
          settings = {
            nixpkgs.expr = "import <nixpkgs> { }";
            formatting.command = [ "nixfmt" ];
            options = {
              nixos.expr = "(builtins.getFlake \"$HOME/nix-config\").nixosConfigurations.MANX.options";
              home_manager.expr = "(builtins.getFlake \"$HOME/nix-config\").nixosConfigurations.MANX.options.home-manager.users.value.${vars.username}";
            };
          };
        };
        pyright.enable = true;
        lua_ls.enable = true;
      };
      keymaps.lspBuf = {
        gd = "definition";
        gr = "references";
        K = "hover";
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
        "<leader>f" = "format";
      };
    };

    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_fallback = true;
          timeout_ms = 500;
        };
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          verilog = [ "verible-verilog-format" ];
          systemverilog = [ "verible-verilog-format" ];
        };
      };
    };

    # High-Performance Syntax Highlighting
    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        systemverilog
        vhdl
        tcl
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

    # =========================================================================
    # CORE PLUGINS & UI
    # =========================================================================
    plugins = {
      aerial.enable = true;
      lualine = {
        enable = true;
        settings.options.theme = "auto";
      };
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
      autopairs.enable = true;
      comment.enable = true;

      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
        };
      };

      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<C-\\>]]";
          direction = "float";
          shade_terminals = false;
          float_opts = {
            border = "curved";
            winblend = 0;
          };
        };
      };
    };

    # =========================================================================
    # KEYMAPS & CUSTOM LOGIC
    # =========================================================================
    globals.mapleader = " ";
    keymaps = [
      {
        mode = "n";
        key = "<C-n>";
        action = ":Neotree toggle<CR>";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree focus<CR>";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = ":Telescope find_files<CR>";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = ":Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>h";
        action = ":nohlsearch<CR>";
      }
      {
        mode = "n";
        key = "<leader>fm";
        action = ":Telescope media_files<CR>";
        options.desc = "Find Media Files";
      }
      {
        mode = "n";
        key = "<leader>o";
        action = ":AerialToggle<CR>";
        options.desc = "Code Outline";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = ":LazyGit<CR>";
        options.desc = "LazyGit";
      }
      {
        mode = "n";
        key = "<leader>qs";
        action = ":lua require('persistence').load()<CR>";
        options.desc = "Restore Session";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action = ":ToggleTerm direction=float<CR>";
      }
      {
        mode = "n";
        key = "<leader>th";
        action = ":ToggleTerm size=15 direction=horizontal<CR>";
      }
      {
        mode = "n";
        key = "<leader>tv";
        action = ":ToggleTerm size=60 direction=vertical<CR>";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = ":bnext<CR>";
      }
      {
        mode = "n";
        key = "<S-h>";
        action = ":bprev<CR>";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = ":bdelete<CR>";
      }
    ];

    extraConfigLua = ''
      -- =========================================================================
      -- AMBXST DYNAMIC THEME INTEGRATION
      -- =========================================================================

      local function sync_ambxst_theme()
        local cache_path = vim.fn.expand("~/.cache/ambxst/colors.json")
        local f = io.open(cache_path, "r")
        if not f then return end
        
        local content = f:read("*all")
        f:close()
        
        -- Decode JSON using Neovim built-in parser
        local ok, colors = pcall(vim.json.decode, content)
        if not ok then return end

        -- Apply basic terminal colors to Neovim
        vim.o.termguicolors = true
        
        -- Force dynamic background transparency
        local groups = { 
            "Normal", "NormalFloat", "FloatBorder", "LineNr", 
            "CursorLineNr", "NeoTreeNormal", "NeoTreeNormalNC",
            "WinSeparator", "TelescopeBorder", "TelescopeNormal"
        }
        for _, group in ipairs(groups) do
            vim.api.nvim_set_hl(0, group, { bg = "none" })
        end

        -- Sync accents with ambxst (Example: using the theme's blue/primary color)
        local accent = colors.blue or colors.sourceColor or "#ffb59e"
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = accent, bg = "none" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = accent, bold = true })
        
        -- Sync Neovim Dashboard with Ambxst accents!
        vim.api.nvim_set_hl(0, "DashboardHeader", { fg = accent, bold = true })
        vim.api.nvim_set_hl(0, "DashboardIcon", { fg = accent })
        vim.api.nvim_set_hl(0, "DashboardKey", { fg = accent })
      end

      -- Run sync on startup
      sync_ambxst_theme()

      -- Neovide Specific Optimizations
      if vim.g.neovide then
        vim.g.neovide_transparency = 0.95
        vim.o.guifont = "JetBrains Mono Nerd Font:h14"
      end

      -- VLSI Detection
      vim.filetype.add({
        extension = { 
            sc = "cpp", 
            v = "verilog", 
            sv = "systemverilog",
            sp = "spice",
            spice = "spice",
            tcl = "tcl"
        },
      })

      -- Custom Telescope Previewer to cleanly intercept binary and media files
      local previewers = require("telescope.previewers")
      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        filepath = vim.fn.expand(filepath)
        
        -- Check file extension
        local ext = vim.fn.fnamemodify(filepath, ":e"):lower()
        local binary_exts = { "png", "jpg", "jpeg", "webp", "gif", "pdf", "zip", "tar", "gz" }
        
        if vim.tbl_contains(binary_exts, ext) then
          -- Show a clean message instead of binary characters!
          require("telescope.previewers.utils").set_preview_message(
            bufnr,
            opts.winid,
            "Binary / Media (Space + f + m for Preview)"
          )
          return
        end
        
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end

      -- Setup custom maker
      require("telescope").setup({
        defaults = {
          buffer_previewer_maker = new_maker
        }
      })
    '';
  };
}
