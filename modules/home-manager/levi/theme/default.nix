{ pkgs, ... }:

{
  imports = [
    ./qt.nix
    ./gtk.nix
  ];

  config = {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;

      # If not using Breeze for qt and we don't wanna pull down all of Breeze
      # just for the cursors, capitaine-cursors (32) is a good alternative.
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 24;
    };
  };
}
