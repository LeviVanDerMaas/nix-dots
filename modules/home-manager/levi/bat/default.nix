{ pkgs, overlays, ... }:

{
  nixpkgs.overlays = [ overlays.catppuccinThemes ];

  programs.bat = {
    enable = true;
    themes = {
      catppuccinMocha = {
        src = pkgs.catppuccin-bat-mocha;
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
    config = {
      theme = "catppuccinMocha";
    };
  };
}
