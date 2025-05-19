{ pkgs, ... }:

{
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
