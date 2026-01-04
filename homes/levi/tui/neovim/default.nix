{ flake-inputs, ... }:

{
  imports = [ flake-inputs.levisNeovimConfig.homeManagerModules.default ];

  config = {
    programs.levisNeovimConfig.enable = true;
  };
}

# {
#   xdg.configFile."nvim/lua".source = ./lua;
#
#   programs.neovim = let
#     vsLua = str: "lua << EOF\n${str}\nEOF\n";
#     vsRequireSetup = mod: vsLua "require('${mod}').setup()";
#     vsPluginSetup = str: vsLua "require 'plugin_setups.${str}'";
#   in {
#     enable = true;
#     extraLuaConfig = builtins.readFile ./init.lua;
#
#     defaultEditor = true;
#
#     viAlias = true;
#     vimAlias = true;
#     vimdiffAlias = true;
#
#     extraPackages = with pkgs; [
#       nodejs_22 # Required for copilot-vim
#       ripgrep # Optional dep for telescope, faster live grep
#       fd # Optional dep for telescope, faster file finding
#       wl-clipboard # Required for clipboard sync
#       zathura # For texlive
#
#       # Language servers
#       clang-tools
#       lua-language-server
#       metals
#       nixd
#       typescript-language-server
#       pyright
#     ];
#
#     # The gist of how (neo)vim configuration, particularly for plugins, works (assuming no flags or special env vars):
#     # - On startup, look for an `init.{vim,lua}` file and run it. `:h init.lua`.
#     # - Beyond that, any script that adds or configures neovim features and any data that is
#     #   to be "provided" to neovim features is stored in directories under `'runtimepath'` and
#     #   packages under`'packpath'` (but this defaults to `'runtimepath'`). When the manual mentions
#     #   nvim using certain dirs, those dirs are almost always found through this. `:h 'runtimepath'`
#     # - Of particular interest for user configuration and plugins are the `autoload`, `lua` and
#     #   `plugin` directories.
#     #     - `autoload`:  define vimscript functions (and variables) lazily; these are not ran on
#     #       startup, but if you call a function or variable that doesn't exist but is defined here, it
#     #       will be automatically defined as given here. `:h autoload`
#     #     - `lua`: the neovim-api equivalent for autoload. Any lua script inside here can be called
#     #       using `require(name)`. `:h lua-module-load`. You may use either `.` or `.` as a directory
#     #       seperator, you can also call a directory if it contains an `init.lua`.
#     #     - `plugin`: Any lua or vimscript file underneath here is automatically executed upon
#     #       start; directories inside here are traversed recursively.
#     # - A "package" is *essentially* just a collection of directories that each contain
#     #   `'runtimepath'`-directories. The idea is that plugins are placed into a package so that they
#     #   do not have to concern themselves with their files conflicting with others, among other
#     #   benefits.
#     #     - Packages are stored inside a `pack` directory and this directory is searched for under
#     #       `packpath`.
#     #     - `pack/*/start/`: these directories are searched after (neo)vim is unable to find
#     #       a runtime-directory under `runtimepath`. Aditionally, the files in any `plugin`
#     #       directories under here are executed on startup (recursively).
#     #     - `~pack/*/opt/`: neovim does not search any runtime-directories under here nor execute
#     #       anything from here by default. However, any packages underneath here can be "loaded"
#     #       using `:packadd`. This adds the package to `runtimepath` and automatically runs its
#     #       `plugin` directory.
#     #     - As you can image managing plugins like this manually sucks, so typically people use
#     #       plugin managers (but most still use this system under the hood).
#     #     - Modern neovim plugins *should* have a lightweight `plugin` directory that only does
#     #     strictly necessary setup and put everything else in the other runtime-directories so that users can "transparently"
#     #       lazy-load the plugin in their config. Unfortuantely not every plugin does that. `:h
#     #       lua-plugin-lazy`.
#
#     # It is not immedieatly clear from the vim manual, but "packages" are 
#     # *essentially* just 
#     # The gist of how plugins work:
#     # - They are just ordinary scripts which execute in the context of nvim
#     # - Like 
#     plugins = with pkgs.vimPlugins; [
#       # Completion
#       {
#         # Completion engine
#         plugin = nvim-cmp;
#         config = vsPluginSetup "nvim-cmp";
#       }
#       luasnip # Snippet engine
#       cmp_luasnip # Makes luasnip work with nvim-cmp
#       cmp-nvim-lsp-signature-help
#       cmp-buffer # cmp source for buffer words
#       cmp-path # cmp source for paths
#       cmp-cmdline # cmp source for cmdline
#       cmp-calc # cmp source for calculations
#       copilot-cmp # cmp source for copilot
#
#       # Treesitter
#       {
#         #TODO: May want to consider specifically excluding the latex grammar.
#         # Nixpkgs manual suggests installing treesitter grammars via either
#         # `.withAllGrammars` or `.withPlugins (p: [..])`. Through a somewhat
#         # convoluted process in nixpkgs, all selected parsers are then made
#         # available as plugins in a `pack` dir in the store under the `start`
#         # dir, where each plugin has a single `parser` dir in the root which
#         # contains the corresponding parser. This approach works but has some disadvantages.
#         # - Primarly it is liable to cause the treesitter plugin to be unable
#         #   to locate any of the installed parsers when loaded with an external
#         #   plugin manager (especially if it disables normal plugin loading, like
#         #   lazy.nvim)
#         # - Furthermore, since `pack`-based autoloading (plugin's under the
#         #   package's `start` dir) effectively inserts each loaded plugin into
#         #   the runtimepath via wildcards, this bloats your runtime path with a
#         #   bunch of plugins for individual parsers: it also causes Treesitter
#         #   to potentially search the parser directories of *all* plugins
#         #   whenver it tries to load a parse (this probably doesn't noticably
#         #   affect performance all that much, nontheless it's more neat to not
#         #   do this).
#         # So instead, what we do is include just the treesitter plugin, without
#         # `.withAllGrammars` or .`withPlugins`, so that parsers are not added
#         # as plugins. Instead we can symlink the parsers directly to a single
#         # `parser` dir that is included in our rtp (like `~/.config`). When we
#         # call `.withAllGrammars` or `.withPlugins`, properly working
#         # derivations for all specified parsers are made available in
#         # `.dependencies` (this is a passthru attribute, so no duplicate neovim
#         # instance is realised) e.g. `.withAllGrammars.dependencies`.
#         plugin = nvim-treesitter.withAllGrammars;
#         config = vsPluginSetup "treesitter";
#       }
#
#       # LSP
#       {
#         # Configs for built-in LSPs for many languages
#         plugin = nvim-lspconfig;
#         config = vsPluginSetup "lsp";
#       }
#       cmp-nvim-lsp # nvim-cmp source for built-in LSP client
#       lspkind-nvim # Adds icons to built-in lsp (requires patched font)
#       {
#         # LSP progress notifications (for lsps using $/progress handler)
#         plugin = fidget-nvim;
#         config = vsRequireSetup "fidget";
#       }
#       neodev-nvim # Should replace this with lazydev.nvim at some point
#
#       # Copilot
#       copilot-lua # Pure lua version of copilot.vim
#
#       # Git
#       vim-fugitive # Git wrapper for nvim
#       {
#         # Add signs for git to the sign column, and more
#         plugin = gitsigns-nvim;
#         config = vsPluginSetup "gitsigns"; 
#       }  
#
#       # UI
#       {
#         plugin = catppuccin-nvim;
#         config = vsLua ''require('catppuccin').setup {
#           flavour = 'mocha',
#           float = { transparent = true }
#         }
#         vim.cmd.colorscheme 'catppuccin'
#         '';
#       }
#       {
#         # Statusline
#         plugin = lualine-nvim;
#         config = vsPluginSetup "lualine"; 
#       }
#       {
#         # Shows key-maps in pop-up (with delay)
#         plugin = which-key-nvim;
#         config = vsRequireSetup "which-key";
#       }
#
#       # Latex
#       # {
#       #   plugin = vimtex;
#       #   config = vsPluginSetup "vimtex"; 
#       # }
#
#       # Telescope
#       {
#         plugin = telescope-nvim;
#         config = vsPluginSetup "telescope"; 
#       }
#       telescope-fzf-native-nvim # Better sorting performance for telescope
#       telescope-ui-select-nvim # Replace vim.ui.select with telescope
#
#       # Code-editing
#       vim-sleuth # Automatic heuristic setting of shiftwidth and expandtab
#       rainbow-delimiters-nvim # Rainbow brackets, braces, etc. #NOTE: CAN INTEGRATE WITH INDENT BLANK LINES IF WE CONFIG THAT, check GH readme
#
#       {
#         # Operator-based inserting and deleting of (, ", <tag>, etc.
#         plugin = nvim-surround;
#         config = vsRequireSetup "nvim-surround";
#       }
#       {
#         # Adds indentation guides
#         plugin = indent-blankline-nvim;
#         config = vsRequireSetup "ibl";
#       }
#       {
#         # Better commenting than built-in
#         plugin = comment-nvim;
#         config = vsRequireSetup "Comment";
#       }
#
#       # Misc
#       plenary-nvim # Dependency for some plugins, such as telescope
#     ];
#   };
# }
