{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;

    gtk.enable = true;
    x11.enable = true;

    package = pkgs.kdePackages.breeze;
    name = "breeze_cursors";
    size = 24;
  };
}
