{ pkgs, config, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
  };

  xdg.configFile."yazi/theme.toml".source = "${pkgs.catppuccin-yazi-mocha-blue}/theme.toml";
}
