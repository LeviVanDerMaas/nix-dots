# NOTE: Be really careful when setting gtk or qt settings beyond
# enabling them, as it may cause issues in DE's if those DE's assume
# they are set to certain values or otherwise like to control them,
# for example Plasma DE will not start if platformtheme is set to
# certain values such as gtk. Hence consider setting any further settings
# within DE's/WM's themselves.
{ pkgs, ... }:

{
  gtk = {
    # THEMING NAMES stolen from whatever KDE sets in xsettingsd/xsettingsd.conf
    # when setting dark themes via that. Figuring out these inconsistencies are
    # needed to make it work was painful.
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    cursorTheme = {
      # name = "catppuccin-mocha-dark-cursors";
      # package = pkgs.catppuccin-cursors.mochaDark;
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Breeze-Dark";
      color-scheme = "prefer-dark";
    };
  };

  qt = {
    enable = true;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    # name = "catppuccin-mocha-dark-cursors";
    # package = pkgs.catppuccin-cursors.mochaDark;
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
    size = 24;
  };

  home.packages = with pkgs; [
    # Dependencies that are needed to make qt style plugins actually be able to properly
    # mimic the gtk style
    libsForQt5.qtstyleplugins
    kdePackages.qt6gtk2

    # Still needed because it has some features that certain Qt apps (mainly KDE native ones) need
#     kdePackages.breeze 
# pkgs.kdePackages.breeze-icons
    # libsForQt5.breeze # Unlikely to be needed because breeze6 should be backwards compatible.
  ];
}
