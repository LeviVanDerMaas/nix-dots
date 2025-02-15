{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.kde;
in
{
  imports = [
    ./breeze
    ./dolphin
  ];

  config = {
    xdg.configFile = {
      # Various KDE apps (and the Breeze theme) need further configuration
      # via these files, and if they are not present or properly configed some
      # of their features might not work.
      "kdeglobals".source = ./kdeglobals;
      "menus/plasma-applications.menu".source = ./plasma-applications.menu;
    };
  };
}
