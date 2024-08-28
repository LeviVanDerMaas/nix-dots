{ pkgs, ... }:

{
  programs.neovim =
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in
  {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      nodejs_22 # Required for copilot-vim
      ripgrep # Required for telescope
      wl-clipboard # Required for clipboard sync
    ];

    plugins = with pkgs.vimPlugins; [
      # Completion
      nvim-cmp # Completion engine # REQUIRES CONFIG
      luasnip # Snippet engine
      cmp_luasnip # Makes luasnip work with nvim-cmp

      # Treesitter
      nvim-treesitter.withAllGrammars #REQUIRES CONFIG
      # nvim-treesitter-text-objects?

      # LSP
      nvim-lspconfig # Configs for built-in LSP for many languages # REQUIRES CONFIG
      cmp-nvim-lsp # nvim-cmp source for built-in LSP client
      lspkind-nvim # Adds icons to built-in lsp (requires patched font)
      {
        # LSP progress notifications (for lsps using $/progress handler)
        plugin = fidget-nvim;
        config = toLua "require('fidget').setup({})";
      }
      # lazydev.nvim?

      
      # Copilot
      copilot-lua # Pure lua version of copilot.vim
      copilot-cmp # nvim-cmp source for copilot
      # copilot.lua?

      # Git
      vim-fugitive # Git wrapper for nvim
      # gitsigns.nvim?

      # UI
      # onedark?
      # lualine?
      {
        # Shows key-maps in pop-up (with delay)
        plugin = which-key-nvim;
        config = toLua "require('which-key').setup()";
      }

      # Telescope
      telescope-nvim #REQUIRES CONFIG
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
  };    
        
  # xdg.configFile.nvim.source = ./config;
}
