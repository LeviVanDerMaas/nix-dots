# NOTE: Be really careful when setting gtk or qt settings beyond
# enabling them, as it may cause issues in DE's if those DE's assume
# they are set to certain values or otherwise like to control them,
# for example Plasma DE will not start if platformtheme is set to
# certain values such as gtk. Hence consider setting any further settings
# within DE's/WM's themselves.
{ pkgs, ... }:

let
  themePackage = pkgs.kdePackages.breeze-gtk;
  themeName = "Breeze-Dark";

  iconThemePackage = pkgs.kdePackages.breeze-icons;
  iconThemeName = "breeze-dark";

  cursorThemePackage = pkgs.capitaine-cursors;
  cursorThemeName = "capitaine-cursors";
  cursorSize = 32;
in
{
  # QT by design really likes to assume there is an engine or DE managing
  # stuff, unfortunately that makes it a pain to make QT-apps use breeze dark
  # (as the default is breeze light, but there are no qt options to configure
  # this mode). A hack is to use Breeze-Dark for gtk, then tell QT apps mimic
  # the GTK style using qtstyleplugins.
  qt = {
    enable = true;
  };

  gtk = {
    # THEMING NAMES stolen from whatever KDE sets in xsettingsd/xsettingsd.conf
    # when setting dark themes via that. Figuring out these inconsistencies are
    # needed to make it work was painful.
    enable = true;
    theme = {
      name = themeName;
      package = themePackage;
    };
    iconTheme = {
      name = iconThemeName;
      package = iconThemePackage;
    };
    cursorTheme = {
      # Slightly more fancy than breeze_cursors IMO, plus breeze cursors does not currently have a
      # stand-alone package on nix, so we'd install the full theme just for the cursors.
      name = cursorThemeName;
      package = cursorThemePackage;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = cursorThemeName;
    package = cursorThemePackage;
    size = cursorSize;
  };

  # Some software will only behave with theming if you set this, especially
  # software that has heavy integration with DE's normally (e.g. Dolphin). A
  # little bird told me that the reason 'the 'gnome' key works for these
  # settings outside of gnome is because of legacy reasons specifically on
  # NixOS.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = themeName;
      icon-theme = iconThemeName;
      cursor-theme = cursorThemeName;
      cursor-size = cursorSize;
    };
  };

  home.packages = with pkgs; [
    # Dependencies that are needed to make qt style plugins actually be able to properly
    # mimic the gtk style
    libsForQt5.qtstyleplugins
    kdePackages.qt6gtk2
  ];
}
