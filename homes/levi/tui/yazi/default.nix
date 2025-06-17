{ pkgs, config, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";

    settings = {
      # Soon to be deprecated for mgr
      manager = {
        ratio = [1 2 5];
        scrolloff = 8;
      };
    };

    # prepend: higher priority than default; append: lower priority than default
    # assigning to keymap directly would effectively remove all default keymaps.
    keymap = {
      # manager soon to be deprecated for mgr.
      manager.prepend_keymap = [
        # Process
        { on = "q"; run = "quit --no-cwd-file"; desc = "Quit without outputting cwd-file"; }
        { on = "Q"; run = "quit"; desc = "Quit the process"; }
        { on = "<C-c>"; run = "close --no-cwd-file"; desc = "Close the current tab, or quit if it's last"; }

        # Navigation
        { on = "K"; run = "seek -10"; desc = "Seek up 10 units in the preview"; }
        { on = "J"; run = "seek 10"; desc = "Seek down 10 units in the preview"; }
        { on = "z"; run = "plugin zoxide"; desc = "Jump to a directory via zoxide"; }
        { on = "Z"; run = "plugin fzf"; desc = "Jump to a file/directory via fzf"; }


        # Selection
        { on = "<S-Space>"; run = "toggle"; desc = "Toggle the current selection state (no hover move)"; }
      ];
    };
  };

  xdg.configFile."yazi/theme.toml".source = "${pkgs.catppuccin-yazi-mocha-blue}/theme.toml";
}
