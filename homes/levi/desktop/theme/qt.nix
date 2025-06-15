{ pkgs, lib, config, ... }:

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

  xdg.configFile = let
    toStr = builtins.toString;
    toINI = lib.generators.toINI {};
    confDir = v: "qt${toStr v}ct";
    confFile = v: "${confDir v}/qt${toStr v}ct.conf";
    colorsFile = v: "${confDir v}/colors/catppuccin-mocha-blue-breeze.conf";
    absColorsFile = v: "${config.xdg.configHome}/${colorsFile v}";

    sharedConf = {
      Appearance = {
        custom_palette = "true";
        icon_theme = "breeze-dark";
        standard_dialogs = "default";
        style = "Breeze";
      };
      Interface = {
        activate_item_on_single_click = "1";
        buttonbox_layout = "0";
        cursor_flash_time = "1000";
        dialog_buttons_have_icons = "1";
        double_click_interval = "400";
        keyboard_scheme = "2";
        menus_have_icons = "true";
        show_shortcuts_in_context_menus = "true";
        toolbutton_style = "4";
        underline_shortcut = "1";
        wheel_scroll_lines = "3";
      };
      Troubleshooting = {
        force_raster_widgets = "1";
      };
    };

    # qt6 expects slightly different config values from qt5 for color schemes.
    # In the case of colorschemes (assuming we aim for a consistent coloring
    # between both versions) these differences are only at the end. Not
    # entirely sure what changes but I have checked that this is also consist
    # with what happens in Breeze and Catppuccin-KDE and as far as I can tell
    # the theme is consist between qt5 and qt6 apps, so whatever.
    colorsConf = v: { 
      ColorScheme = {
        active_colors = "#ffcdd6f4, #ff313244, #ff3d3d5e, #ff2f2f48, #ff0c0c12, #ff151520, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff181825, #ff09090d, #ff89b4fa, #ff11111b, #ff89b4fa, #ffcba6f7, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, "
          + "${if v == 5 then "#806c7086" else "#ffa6adc8, #ff89b4fa"}";
        disabled_colors = "#ff6c7086, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff181825, #ff6c7086, #ffcdd6f4, #ff6c7086, #ff1e1e2e, #ff181825, #ff11111b, #ff181825, #ff6c7086, #ffa9bcdb, #ffc7cceb, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086"
          + "${if v == 5 then "" else ", #ff181825"}";
        inactive_colors = "#ffcdd6f4, #ff313244, #ff3d3d5e, #ff2f2f48, #ff0c0c12, #ff151520, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff181825, #ff09090d, #ff89b4fa, #ff11111b, #ff89b4fa, #ffcba6f7, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, "
          + "${if v == 5 then "#806c7086" else "#ffa6adc8, #ff89b4fa"}";
      };
    }; 
  in {
    "${confFile 5}".text = toINI (lib.recursiveUpdate 
      sharedConf 
      {
        Appearance = {
          color_scheme_path = absColorsFile 5;
        };
        Fonts = {
          fixed = "\"Noto Sans,10,-1,5,50,0,0,0,0,0,Regular\"";
          general = "\"Noto Sans,10,-1,5,50,0,0,0,0,0,Regular\"";
        };
      }
    );
    "${confFile 6}".text = toINI (lib.recursiveUpdate 
      sharedConf
      {
        Appearance = {
          color_scheme_path = absColorsFile 6;
        };
        Fonts = {
          fixed = "\"Noto Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular\"";
          general = "\"Noto Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular\"";
        };
      }
    );


    "${colorsFile 5}".text = toINI (colorsConf 5);
    "${colorsFile 6}".text = toINI (colorsConf 6);
  };

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
