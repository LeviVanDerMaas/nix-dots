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
        # Nixpkgs manual suggests installing treesitter grammars via either
        # `.withAllGrammars` or `.withPlugins (p: [..])`. Through a somewhat
        # convoluted process in nixpkgs, all selected parsers are then made
        # available as plugins in a `pack` dir in the store under the `start`
        # dir, where each plugin has a single `parser` dir in the root which
        # contains the corresponding parser. This approach works but has some disadvantages.
        # - Primarly it is liable to cause the treesitter plugin to be unable
        #   to locate any of the installed parsers when loaded with an external
        #   plugin manager (especially if it disables normal plugin loading, like
        #   lazy.nvim)
        # - Furthermore, since `pack`-based autoloading (plugin's under the
        #   package's `start` dir) effectively inserts each loaded plugin into
        #   the runtimepath via wildcards, this bloats your runtime path with a
        #   bunch of plugins for individual parsers: it also causes Treesitter
        #   to potentially search the parser directories of *all* plugins
        #   whenver it tries to load a parse (this probably doesn't noticably
        #   affect performance all that much, nontheless it's more neat to not
        #   do this).
        # So instead, what we do is include just the treesitter plugin, without
        # `.withAllGrammars` or .`withPlugins`, so that parsers are not added
        # as plugins. Instead we can symlink the parsers directly to a single
        # `parser` dir that is included in our rtp (like `~/.config`). When we
        # call `.withAllGrammars` or `.withPlugins`, properly working
        # derivations for all specified parsers are made available in
        # `.dependencies` (this is a passthru attribute, so no duplicate neovim
        # instance is realised) e.g. `.withAllGrammars.dependencies`.
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
        config = vsLua ''require('catppuccin').setup {
          flavour = 'mocha',
          float = { transparent = true }
        }
        vim.cmd.colorscheme 'catppuccin'
        '';
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
      # {
      #   plugin = vimtex;
      #   config = vsPluginSetup "vimtex"; 
      # }

      # Telescope
      {
        plugin = telescope-nvim;
        config = vsPluginSetup "telescope"; 
      }
      telescope-fzf-native-nvim # Better sorting performance for telescope
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
