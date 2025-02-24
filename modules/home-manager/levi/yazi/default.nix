{ pkgs, overlays, config, lib, ... }:

{
  nixpkgs.overlays = [ overlays.catppuccinThemes ];

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
  };

  xdg.configFile."yazi/theme.toml".source = "${pkgs.catppuccin-yazi-mocha-blue}/theme.toml";
}
