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

  # It doesn't seem possible to set Breeze Dark to be used directly
  # through the qt module for nix, however you can make Breeze Dark
  # the theme of gtk and then coax qt to follow the gtk style, which
  # should work for most appplications
  qt = {
    enable = true;
    # platformTheme.name = "gtk"; # This will be converted to gtk2 and be set as QT_QPA_PLATFORMTHEME. It will also install qtstyleplugins and qt6gtk2 provided platformTheme.package is not set.
    # style = {
    #   name = "gtk2"; # Will set QT_STYLE_OVERRIDE to gtk2. Will also set style.package to default to [ qtstyleplguins qt6gtk2 ].
    #   package = pkgs.kdePackages.breeze; # Will install whatever is set here
    # };
  };

  home.packages = with pkgs; [
    kdePackages.breeze
    libsForQt5.qtstyleplugins
    kdePackages.qt6gtk2
  ];
}
