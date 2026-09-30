{ lib, fns, osConfig ? {}, outputs, ... }:

{
  imports = fns.discoverOtherNixFilesAt ./default.nix;

  config = {
    programs.home-manager.enable = true;

    home = {
      username = "levi";
      homeDirectory = "/home/levi";
    };

    # The nixpkgs module is disabled when using useGlobalPkgs, in which case
    # the config and overlays available also come from that.
    nixpkgs = lib.mkIf (osConfig.nixpkgs.home-manager.useGlobalPkgs or false) {
      # Be wary: if the pkgs instance this was built with already has these values
      # they will *also* be used (in case of config they are set as defaults).
      config = fns.rootRelImport "nixpkgs-config.nix";
      overlays = builtins.attrValues outputs.overlays;
    };





    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.05"; # note that this is an unstable version
  };
}
