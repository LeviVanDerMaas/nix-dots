{ pkgs, ... }:

{
  qt.enable = true;
  gtk.enable = true; 
  home.packages = with pkgs; [
    # Hyprland must use these for theming, as it is not a full DE and thus does not have
    # gtk or qt integration.
    # libsForQt5.qt5ct
    # kdePackages.qt6ct
    # kdePackages.breeze
    # kdePackages.breeze-gtk
    # kdePackages.breeze-icons
    # nwg-look
  ];
  wayland.windowManager.hyprland.settings.env = [
    # "QT_QPA_PLATFORMTHEME,qt5ct"
  ];
}
