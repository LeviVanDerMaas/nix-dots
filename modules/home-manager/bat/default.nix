{ inputs, ... }:

{
  programs.bat = {
    enable = true;
    themes = {
      catppuccinMocha = {
        src = inputs.batThemeCatppuccin;
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
    config = {
      theme = "catppuccinMocha";
    };
  };
}
