{ pkgs, ... }:

{
  programs.neovim = let
    # Wrap lua strings in :lua, turning it into vimscript expression.
    luaChunk = str: "lua << EOF\n${str}\nEOF\n";
    luaChunckFile = file:  "lua << EOF\n${builtins.readFile file}EOF\n";

    # Wrap lua in 'do-end' block, limiting the scope to that piece of lua.
    scopeLua = str: "do\n${str}\nend\n";
    scopeLuaFile = file: "do\n${builtins.readFile file}end\n";
    scopeLuaFiles = files: let
      blocks = builtins.map (f: scopeLuaFile f) files;
    in builtins.concatStringsSep "\n" blocks;
  in {
    enable = true;

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
        config = luaChunckFile ./plugins/nvim-cmp.lua;
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
        config = luaChunckFile ./plugins/treesitter.lua;
      }

      # LSP
      {
        # Configs for built-in LSPs for many languages
        plugin = nvim-lspconfig;
        config = luaChunckFile ./plugins/lsp.lua;
      }
      cmp-nvim-lsp # nvim-cmp source for built-in LSP client
      lspkind-nvim # Adds icons to built-in lsp (requires patched font)
      {
        # LSP progress notifications (for lsps using $/progress handler)
        plugin = fidget-nvim;
        config = luaChunk "require('fidget').setup({})";
      }
      neodev-nvim # Should replace this with lazydev.nvim at some point

      # Copilot
      copilot-lua # Pure lua version of copilot.vim

      # Git
      vim-fugitive # Git wrapper for nvim
      {
        # Add signs for git to the sign column, and more
        plugin = gitsigns-nvim;
        config = luaChunckFile ./plugins/gitsigns.lua;
      }

      # UI
      {
        plugin = catppuccin-nvim;
        config = "colorscheme catppuccin-mocha";
      }
      {
        # Statusline
        plugin = lualine-nvim;
        config = luaChunckFile ./plugins/lualine.lua;
      }
      {
        # Shows key-maps in pop-up (with delay)
        plugin = which-key-nvim;
        config = luaChunk "require('which-key').setup()";
      }

      # Latex
      {
        plugin = vimtex;
        config = luaChunckFile ./plugins/vimtex.lua;
      }

      # Telescope
      {
        plugin = telescope-nvim;
        config = luaChunckFile ./plugins/telescope.lua;
      }
      telescope-ui-select-nvim # Replace vim.ui.select with telescope

      # Code-editing
      vim-sleuth # Automatic heuristic setting of shiftwidth and expandtab
      rainbow-delimiters-nvim # Rainbow brackets, braces, etc.

      {
        # Operator-based inserting and deleting of (, ", <tag>, etc.
        plugin = nvim-surround;
        config = luaChunk "require('nvim-surround').setup()";
      }
      {
        # Adds indentation guides
        plugin = indent-blankline-nvim;
        config = luaChunk "require('ibl').setup()";
      }
      {
        # Better commenting than built-in
        plugin = comment-nvim;
        config = luaChunk "require('Comment').setup()";
      }

      # Misc
      plenary-nvim # Dependency for some plugins, such as telescope
    ];

    # MAKE SURE to SCOPE external code (like files) so that local variables etc.
    # will not enter the global namespace in init.lua.
    extraLuaConfig = scopeLuaFiles [
      ./options.lua  # Should come first
      ./util.lua # Should come second
      ./keymaps.lua
      ./commands.lua
    ];
  };
}
