{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.kde.breeze.cursors;
in
{
  options.modules.home-manager.levi.kde.breeze.cursors = {
    enable = lib.mkEnableOption ''
      Installs and enables Breeze6 cursors. Note that this will pull down the
      entire Breeze6 theme, since Breeze cursors are part of the Breeze
      package. If you do not want to pull down the full Breeze package just for
      the cursors, a good alternative is "capitaine-cursors", which is a cursor
      set that is strongly inspired by Breeze.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;

      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 24;
    };
  };
}
