# NOTE: Be really careful when setting gtk or qt settings beyond
# enabling them, as it may cause issues in DE's if those DE's assume
# they are set to certain values or otherwise like to control them,
# for example Plasma DE will not start if platformtheme is set to
# certain values such as gtk. Hence consider setting any further settings
# within DE's/WM's themselves.
{ pkgs, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    cursorTheme = {
      name = "Breeze-Dark";
      # Breeze includes its cursor in the global theme
      package = pkgs.kdePackages.breeze-gtk;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
  };

  home.packages = with pkgs; [
    # Dependencies that are needed to make qt style plugins actually be able to properly
    # mimic the gtk style
    libsForQt5.qtstyleplugins
    kdePackages.qt6gtk2

    # Still needed because it has some features that certain Qt apps (mainly KDE native ones) need
    kdePackages.breeze 
    # libsForQt5.breeze # Unlikely to be needed because breeze6 should be backwards compatible.
  ];
}
