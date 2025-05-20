{ pkgs, config, lib, ... }:

let
  cfg = config.modules.kde;
in
{
  imports = [
    ./breeze
    ./dolphin
  ];

  options.modules.kde = { 
    symlink-kdeglobals = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to symlink this config's kdeglobals file into .config/kdeglobals.
        You will want to turn this off if you are also installing Plasma, as
        Plasma does not handle it well if it does not have write access to this file.
      '';
    };
  };

  config = {
    xdg.configFile = {
      # Various KDE apps (and the Breeze theme) need further configuration
      # via these files, and if they are not present or properly configed some
      # of their features might not work.
      ${if cfg.symlink-kdeglobals then "kdeglobals" else null}.source = ./kdeglobals;
      "menus/plasma-applications.menu".source = ./plasma-applications.menu;
    };
  };
}
