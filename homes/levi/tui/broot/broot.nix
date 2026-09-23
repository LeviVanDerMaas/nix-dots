{ pkgs, fns, ... }:
{

  programs.bash.shellAliases = {
    br = "br --listen-auto";
    b = "br";
  };

  programs.broot = {
    enable = true;
    enableBashIntegration = true;

    # NOTE: The HM module works a bit weirdly: it takes the auto-generated
    # default config file and uses jq to merge your settings with it. It
    # only does this at the top level though, so effectively anything you
    # set here (including arrays) will override the default values.
    settings = {
      imports = []; # Ensure imports empty because of aformentioned reasons.

      default_flags = "-g";
      modal = true;
      initial_mode = "command";

      terminal_title = "br: {file}";
      lines_before_match_in_preview = 5;
      lines_after_match_in_preview = 5;
      icon_theme = "nerdfont";
      syntax_theme = "MochaDark";

      # List - If false, still sees the directory but do not see the subtree until entered
      # Show - Wheter broot sees the file/dir subtree at all
      # Sum - Whether it should show/compute file/dir size.
      special_paths = {
        ".git" = { list = "never"; };
      };

      verbs = import ./_verbs.nix;
      skin = import ./_skin.nix;
    };
  };
}
