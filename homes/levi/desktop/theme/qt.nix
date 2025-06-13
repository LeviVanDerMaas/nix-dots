{ pkgs, ... }:

{

  # NOTE: Do not use the hm qt-module to install Breeze, it does not install
  # Breeze 6, we should handle installing Breeze 6 (and 5) ourselves.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  home.packages = with pkgs.kdePackages; [
    # Install both breeze5 and breeze6 since qt5 is still very commonplace.
    # Use the qt5 output instead of libsForQt5 to prevent package collisions.
    breeze
    breeze.qt5

    # The HM qt module does not actually seem to ship wayland support by default.
    qtwayland # For Qt6
    pkgs.libsForQt5.qtwayland # for Qt5

    # plasma-integration should make Breeze work and look better in some places,
    # and especially with KDE native apps.
    plasma-integration
    plasma-integration.qt5
  ];


  modules.kde.kdeglobals = {
    UiSettings = {
      # Without setting specifically this key to this value, many config
      # values for Breeze both from kdeglobals and the qt colorscheme
      # are ignored when running outside of Plasma.
      ColorScheme = "*";
    };

    # The colors used here are the Catppuccin Mocha Blue colors. More specifically,
    # I stole them directly from the values the offical Catppuccin-KDE distribution
    # sets when you apply that theme inside KDE.
    "ColorEffects:Disabled" = {
      ChangeSelectionColor = "";
      Color = "30, 30, 46";
      ColorAmount = "0.3";
      ColorEffect = "2";
      ContrastAmount = "0.1";
      ContrastEffect = "0";
      Enable = "";
      IntensityAmount = "-1";
      IntensityEffect = "0";
    };

    "ColorEffects:Inactive" = {
      ChangeSelectionColor = "true";
      Color = "30, 30, 46";
      ColorAmount = "0.5";
      ColorEffect = "3";
      ContrastAmount = "0";
      ContrastEffect = "0";
      Enable = "true";
      IntensityAmount = "0";
      IntensityEffect = "0";
    };

    "Colors:Button" = {
      BackgroundAlternate = "137,180,250";
      BackgroundNormal = "49, 50, 68";
      DecorationFocus = "137,180,250";
      DecorationHover = "49, 50, 68";
      ForegroundActive = "250, 179, 135";
      ForegroundInactive = "166, 173, 200";
      ForegroundLink = "137,180,250";
      ForegroundNegative = "243, 139, 168";
      ForegroundNeutral = "249, 226, 175";
      ForegroundNormal = "205, 214, 244";
      ForegroundPositive = "166, 227, 161";
      ForegroundVisited = "203, 166, 247";
    };

    "Colors:Complementary" = {
      BackgroundAlternate = "17, 17, 27";
      BackgroundNormal = "24, 24, 37";
      DecorationFocus = "137,180,250";
      DecorationHover = "49, 50, 68";
      ForegroundActive = "250, 179, 135";
      ForegroundInactive = "166, 173, 200";
      ForegroundLink = "137,180,250";
      ForegroundNegative = "243, 139, 168";
      ForegroundNeutral = "249, 226, 175";
      ForegroundNormal = "205, 214, 244";
      ForegroundPositive = "166, 227, 161";
      ForegroundVisited = "203, 166, 247";
    };

    "Colors:Header" = {
      BackgroundAlternate = "17, 17, 27";
      BackgroundNormal = "24, 24, 37";
      DecorationFocus = "137,180,250";
      DecorationHover = "49, 50, 68";
      ForegroundActive = "250, 179, 135";
      ForegroundInactive = "166, 173, 200";
      ForegroundLink = "137,180,250";
      ForegroundNegative = "243, 139, 168";
      ForegroundNeutral = "249, 226, 175";
      ForegroundNormal = "205, 214, 244";
      ForegroundPositive = "166, 227, 161";
      ForegroundVisited = "203, 166, 247";
    };

    "Colors:Selection" = {
      BackgroundAlternate = "137,180,250";
      BackgroundNormal = "137,180,250";
      DecorationFocus = "137,180,250";
      DecorationHover = "49, 50, 68";
      ForegroundActive = "250, 179, 135";
      ForegroundInactive = "24, 24, 37";
      ForegroundLink = "137,180,250";
      ForegroundNegative = "243, 139, 168";
      ForegroundNeutral = "249, 226, 175";
      ForegroundNormal = "17, 17, 27";
      ForegroundPositive = "166, 227, 161";
      ForegroundVisited = "203, 166, 247";
    };

    "Colors:Tooltip" = {
      BackgroundAlternate = "27,25,35";
      BackgroundNormal = "30, 30, 46";
      DecorationFocus = "137,180,250";
      DecorationHover = "49, 50, 68";
      ForegroundActive = "250, 179, 135";
      ForegroundInactive = "166, 173, 200";
      ForegroundLink = "137,180,250";
      ForegroundNegative = "243, 139, 168";
      ForegroundNeutral = "249, 226, 175";
      ForegroundNormal = "205, 214, 244";
      ForegroundPositive = "166, 227, 161";
      ForegroundVisited = "203, 166, 247";
    };

    "Colors:View" = {
      BackgroundAlternate = "24, 24, 37";
      BackgroundNormal = "30, 30, 46";
      DecorationFocus = "137,180,250";
      DecorationHover = "49, 50, 68";
      ForegroundActive = "250, 179, 135";
      ForegroundInactive = "166, 173, 200";
      ForegroundLink = "137,180,250";
      ForegroundNegative = "243, 139, 168";
      ForegroundNeutral = "249, 226, 175";
      ForegroundNormal = "205, 214, 244";
      ForegroundPositive = "166, 227, 161";
      ForegroundVisited = "203, 166, 247";
    };

    "Colors:Window" = {
      BackgroundAlternate = "17, 17, 27";
      BackgroundNormal = "24, 24, 37";
      DecorationFocus = "137,180,250";
      DecorationHover = "49, 50, 68";
      ForegroundActive = "250, 179, 135";
      ForegroundInactive = "166, 173, 200";
      ForegroundLink = "137,180,250";
      ForegroundNegative = "243, 139, 168";
      ForegroundNeutral = "249, 226, 175";
      ForegroundNormal = "205, 214, 244";
      ForegroundPositive = "166, 227, 161";
      ForegroundVisited = "203, 166, 247";
    };
  };
}
