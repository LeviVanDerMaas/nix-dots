{ pkgs, fns, ... }:
{

  programs.bash.shellAliases = {
    br = "br --listen-auto";
    b = "br";
  };

  programs.broot = {
    # Override package until next release to pull in some bug fixes for :select and :show
    # https://github.com/Canop/broot/pull/1178
    package = fns.checkPkgVersion pkgs.broot "1.57.0" pkgs.broot.overrideAttrs rec {
      src = pkgs.fetchFromGitHub {
        owner = "Canop";
        repo = "broot";
        rev = "8bcfc57c39bd558805d77dede44e79b0f3924830";
        hash = "sha256-c+2ZWjiHs58zWnPOxCO5sfM0TAZSoMxAJWi8NMZfz1w=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-HTYC4yGohraK6Jc5fwtmezZ4idyLhPAzvatL2PXKAXk=";
      };
    };

    enable = true;
    enableBashIntegration = true;

    # NOTE: The HM module works a bit weirdly: it takes the auto-generated
    # default config file and uses jq to merge your settings with it. It
    # only does this at the top level though, so effectively anything you
    # set here (including arrays) will override the default values.
    settings = {
      imports = []; # Ensure imports empty because of aformentioned reasons.
      default_flags = "-g";
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
        ".cache" = { list = "never"; };
      };

      verbs = import ./verbs.nix;
      skin = import ./skin.nix;
    };
  };
}
