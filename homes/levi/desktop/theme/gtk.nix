{ pkgs, config, lib, ... }:

let
  # WARNING: Offical theme, but archived since Jun 2024.
  themePackage = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard";
    variant = "mocha";
  };
  themeName = "catppuccin-mocha-blue-standard";

  iconPackage = pkgs.kdePackages.breeze-icons;
  iconName = "breeze-dark";

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

  # Some software will only behave with theming if you set this (i.e. adjust
  # font color), especially software that has heavy integration with DEs
  # normally and GTK4 stuff. Also for Wayland software this may work only if
  # the gtk desktop portal is installed.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = themeName;
      icon-theme = iconName;
      cursor-theme = cursorName;
      cursor-size = cursorSize;
    };
  };

  # KDE overwrites this file whenever it gets started, removing it from HM
  # management. This then causes rebuilds to fail since HM wants to control
  # this file, so we let HM force the symlink. Aditionally we must specify the
  # exact same path for this as HM's gtk module otherwise HM's home.file handling
  # thinks there is a conflict (e.g. `/home/levi/.gtkrc-2.0` vs `.gtkrc-2.0`).
  # Aditionally, building without mkForce works, but it will cause errors in some
  # other nix tools, like `nixos-option`, when evaluating this option.
  home.file.${config.gtk.gtk2.configLocation}.force = lib.mkForce true;
}
