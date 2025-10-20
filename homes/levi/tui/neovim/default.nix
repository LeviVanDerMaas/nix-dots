{ pkgs, ... }:

{
  xdg.configFile."nvim/lua".source = ./lua;

  programs.neovim = let
    vsLua = str: "lua << EOF\n${str}\nEOF\n";
    vsRequireSetup = mod: vsLua "require('${mod}').setup()";
    vsPluginSetup = str: vsLua "require 'plugin_setups.${str}'";
  in {
    enable = true;
    extraLuaConfig = builtins.readFile ./init.lua;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      nodejs_22 # Required for copilot-vim
      ripgrep # Optional dep for telescope, faster live grep
      fd # Optional dep for telescope, faster file finding
      wl-clipboard # Required for clipboard sync
      zathura # For texlive

      # Language servers
      clang-tools
      lua-language-server
      metals
      nixd
      typescript-language-server
      pyright
    ];

    plugins = with pkgs.vimPlugins; [
      # Completion
      {
        # Completion engine
        plugin = nvim-cmp;
        config = vsPluginSetup "nvim-cmp";
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
        #TODO: May want to consider specifically excluding the latex grammar.
        # You should be able to access an attrset of all grammars with the
        # packages grammarPlugins attribute (which is how withAllGrammars
        # installs all grammars), and remove the latex attribute from it.
        plugin = nvim-treesitter.withAllGrammars;
        config = vsPluginSetup "treesitter";
      }

      # LSP
      {
        # Configs for built-in LSPs for many languages
        plugin = nvim-lspconfig;
        config = vsPluginSetup "lsp";
      }
      cmp-nvim-lsp # nvim-cmp source for built-in LSP client
      lspkind-nvim # Adds icons to built-in lsp (requires patched font)
      {
        # LSP progress notifications (for lsps using $/progress handler)
        plugin = fidget-nvim;
        config = vsRequireSetup "fidget";
      }
      neodev-nvim # Should replace this with lazydev.nvim at some point

      # Copilot
      copilot-lua # Pure lua version of copilot.vim

      # Git
      vim-fugitive # Git wrapper for nvim
      {
        # Add signs for git to the sign column, and more
        plugin = gitsigns-nvim;
        config = vsPluginSetup "gitsigns"; 
      }

      # UI
      {
        plugin = catppuccin-nvim;
        config = vsLua "vim.cmd.colorscheme 'catppuccin-mocha'";
      }
      {
        # Statusline
        plugin = lualine-nvim;
        config = vsPluginSetup "lualine"; 
      }
      {
        # Shows key-maps in pop-up (with delay)
        plugin = which-key-nvim;
        config = vsRequireSetup "which-key";
      }

      # Latex
      {
        plugin = vimtex;
        config = vsPluginSetup "vimtex"; 
      }

      # Telescope
      {
        plugin = telescope-nvim;
        config = vsPluginSetup "telescope"; 
      }
      telescope-ui-select-nvim # Replace vim.ui.select with telescope

      # Code-editing
      vim-sleuth # Automatic heuristic setting of shiftwidth and expandtab
      rainbow-delimiters-nvim # Rainbow brackets, braces, etc. #NOTE: CAN INTEGRATE WITH INDENT BLANK LINES IF WE CONFIG THAT, check GH readme

      {
        # Operator-based inserting and deleting of (, ", <tag>, etc.
        plugin = nvim-surround;
        config = vsRequireSetup "nvim-surround";
      }
      {
        # Adds indentation guides
        plugin = indent-blankline-nvim;
        config = vsRequireSetup "ibl";
      }
      {
        # Better commenting than built-in
        plugin = comment-nvim;
        config = vsRequireSetup "Comment";
      }

      # Misc
      plenary-nvim # Dependency for some plugins, such as telescope
    ];
  };
}
