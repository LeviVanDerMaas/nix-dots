{ pkgs, config, ... }:

let
  themePackage = pkgs.breeze-gtk;
  themeName = "Breeze-Dark";

  iconPackage = pkgs.kdePackages.breeze-icons;
  iconName = "breeze-dark";

  cursorPackage = config.home.pointerCursor.package;
  cursorName =  config.home.pointerCursor.name;
  cursorSize = config.home.pointerCursor.size;
in
{
  gtk = {
    enable = true;
    theme = {
      package = themePackage;
      name = themeName;
    };
    iconTheme = {
      package = iconPackage;
      name = iconName;
    };
    # cursorTheme = {package name size}; defaults to home.pointerCursor vals.

    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
    gtk4 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  # Some software will only behave with theming if you set this, especially
  # software that has heavy integration with DEs normally and GTK4 stuff. Also
  # for Wayland software this may work only if the gtk desktop portal is installed.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = themeName;
      icon-theme = iconName;
      cursor-theme = cursorName;
      cursor-size = cursorSize;
    };
  };
}
