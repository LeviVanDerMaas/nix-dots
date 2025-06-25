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

      # Yazi uses `find` to get MIMEtypes.
      opener = {
        edit = [{ run = "\${EDITOR:-vi} \"$@\""; block = true; desc = "$EDITOR"; }];
        play = [{ run = "vlc \"$@\""; orphan = true; desc = "VLC Media Player"; }];
        extract = [{ run = "ya pub extract --list \"$@\""; desc = "Extract here"; }];
        gui-manager = [{ run = "dolphin \"$@\""; orphan = true; desc = "Dolphin"; }];
        xdg-open = [{ run = "xdg-open \"$@\""; orphan = true; desc = "Open (XDG)"; }];
      };
      open.rules = [ # override defaults, that is they become unset
        { name = "*/"; use = [ "edit" "xdg-open" "gui-manager" ]; } # folders
        { mime = "text/*"; use = [ "edit" "xdg-open" ]; } # Plain text
        { mime = "{audio,video}/*"; use = [ "play" ]; } # Media
        { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; use = [ "extract" "xdg-open" "gui-manager" ]; }
        
        # Empty file
        { mime = "inode/empty"; use = [ "edit" ]; }
        { mime = "*"; use = [ "xdg-open" ]; }
      ];
    };

    keymap = {
      # manager soon to be deprecated for mgr.
      manager.prepend_keymap = [ # prepend, so prioritizes but does not override defaults
        # Process
        { on = "q"; run = "quit --no-cwd-file"; desc = "Quit without outputting cwd-file"; }
        { on = "Q"; run = "quit"; desc = "Quit the process"; }
        { on = "<C-c>"; run = "close --no-cwd-file"; desc = "Close the current tab, or quit if it's last"; }
        { on = "e"; run = "shell --orphan -- dolphin ."; desc = "Open directory in Dolphin"; }

        # Navigation
        { on = "K"; run = "seek -10"; desc = "Seek up 10 units in the preview"; }
        { on = "J"; run = "seek 10"; desc = "Seek down 10 units in the preview"; }
        { on = "z"; run = "plugin fzf"; desc = "Jump to a file/directory via fzf"; }
        { on = "Z"; run = "plugin zoxide"; desc = "Jump to a directory via zoxide"; }


        # Selection
        { on = "<S-Space>"; run = "toggle"; desc = "Toggle the current selection state (no hover move)"; }
      ];
    };
  };

  xdg.configFile."yazi/theme.toml".source = "${pkgs.catppuccin-yazi-mocha-blue}/theme.toml";
}
