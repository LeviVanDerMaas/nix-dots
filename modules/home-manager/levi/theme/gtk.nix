{ pkgs, config, lib, ... }:

{
  gtk.enable = true;
  modules.home-manager.levi.kde.breeze.gtk = {
    enable = true;
  };
}
