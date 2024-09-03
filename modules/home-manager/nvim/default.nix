{ pkgs, ... }:

{
  programs.neovim =
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in
  {
    enable = true;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      nodejs_22 # Required for copilot-vim
      ripgrep # Required for telescope
      wl-clipboard # Required for clipboard sync

      # Language servers
      clang-tools
      lua-language-server
      nixd
    ];

    plugins = with pkgs.vimPlugins; [
      # Completion
      {
        # Completion engine
        plugin = nvim-cmp;
        config = toLuaFile ./plugins/nvim-cmp.lua;
      }
      luasnip # Snippet engine
      cmp_luasnip # Makes luasnip work with nvim-cmp
      cmp-nvim-lsp-signature-help
      cmp-buffer # cmp source for buffer words
      cmp-path # cmp source for paths
      cmp-cmdline # cmp source for cmdline
      cmp-calc # cmp source for calculations
      copilot-cmp # cmp source for copilot

      # Treesitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = toLuaFile ./plugins/treesitter.lua;
      }

      # LSP
      {
        # Configs for built-in LSPs for many languages
        plugin = nvim-lspconfig;
        config = toLuaFile ./plugins/lsp.lua;
      }
      cmp-nvim-lsp # nvim-cmp source for built-in LSP client
      lspkind-nvim # Adds icons to built-in lsp (requires patched font)
      {
        # LSP progress notifications (for lsps using $/progress handler)
        plugin = fidget-nvim;
        config = toLua "require('fidget').setup({})";
      }
      neodev-nvim # Should replace this with lazydev.nvim at some point

      # Copilot
      copilot-lua # Pure lua version of copilot.vim

      # Git
      vim-fugitive # Git wrapper for nvim
      {
        # Add signs for git to the sign column, and more
        plugin = gitsigns-nvim;
        config = toLuaFile ./plugins/gitsigns.lua;
      }

      # UI
      {
        plugin = catppuccin-nvim;
        config = "colorscheme catppuccin-macchiato";
      }
      {
        # Statusline
        plugin = lualine-nvim;
        config = toLuaFile ./plugins/lualine.lua;
      }
      {
        # Shows key-maps in pop-up (with delay)
        plugin = which-key-nvim;
        config = toLua "require('which-key').setup()";
      }

      # Telescope
      {
        plugin = telescope-nvim;
        config = toLuaFile ./plugins/telescope.lua;
      }
      telescope-ui-select-nvim # Replace vim.ui.select with telescope

      # Code-editing
      vim-sleuth # Automatic heuristic setting of shiftwidth and expandtab
      {
        # Adds indentation guides
        plugin = indent-blankline-nvim;
        config = toLua "require('ibl').setup()";
      }
      {
        # Better commenting than built-in
        plugin = comment-nvim;
        config = toLua "require('Comment').setup()";
      }

      # Misc
      plenary-nvim # Dependency for some plugins, such as telescope

    ];

    extraLuaConfig = ''
      ${builtins.readFile ./helpers.lua}
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keymaps.lua}
      ${builtins.readFile ./commands.lua}
    '';
  };
}
