{ pkgs, lib, config, ... }:

let
  cfg = config.modules.qt;

  # Official KDE config files with catppuccin colors. Already put in proper dir.
  catppuccin-kde-mocha-blue = pkgs.catppuccin-kde.override {
    flavour = [ "mocha" ];
    accents = [ "blue" ];
  };
in
{
  options.modules.qt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable this to home-manager handle theming through qt5ct and qt6ct.
        You'll want to disable this if you are also running a DE that has
        qt-integration, because having this on at the same time will likely
        break Qt theming.
      '';
    };
  };

  config = lib.mkIf cfg.enable { 
    qt = {
      enable = true;
      platformTheme.name = "qtct";
      # Other options in this are inflexible and inconsistent, do it ourself.
    };

    home.packages = with pkgs.kdePackages; [
      # Wayland support: HM Qt module doesn't seem to ship this by default.
      qtwayland # for Qt6
      pkgs.libsForQt5.qtwayland # for Qt5
     
      # Breeze Theme/style:
      breeze # Breeze for Qt6
      breeze.qt5 # Breeze for Qt5 (libsForQt5 pkg causes collisions with Breeze 6).
      catppuccin-kde-mocha-blue
    ];

    # Breeze's color scheme is entirely customizable. Most of the color scheme
    # is applied from values set in KDE config files (this is also actually how
    # Breeze Dark works), but in some cases colors are taken directly from the
    # platformtheme's set QtPallete and so we must configure both (unless the
    # platformtheme we are using were to be `kde`, which seems to configure
    # QtPallete based on the same KDE config files). Aditionally some
    # KDE-native apps seem to need KDE config files for coloring even when
    # using a non-KDE theme.
    #
    # Breeze, and KDE-native apps using the KColorScheme framework directly,
    # find color scheme configuration as follows:
    # 1. Look for an XDG config file named `kdeglobals`.
    # 2. Read its [UiSettings]ColorScheme field, let this be `$s`.
    # 3. Look for an XDG data (`share/`) file named `color-schemes/$s.colors`.
    # 4. Apply all values given in here, like [Colors:Button]ForegroundActive.
    # 5. If the initially found `kdeglobals` file also specifies colors values
    #    AND it has a non-empty [UiSettings]ColorScheme (even if it points to a
    #    non-existent colorscheme), these colors should override the earlier set
    #    ones. However the consistency of this is flakey when not using `kde`
    #    as the platformtheme and prone to behavioural changes between updates.
    # 6. For some reason, in some obscure cases step 4 will fail to apply to 
    #    certain UI elements (e.g. the text in the menu bar of VLC media
    #    player). In these cases step 5 seems to fix the issue consistently
    #    even when not running under the kde platformtheme. This weird
    #    occurence may also be the reason why setting a different colorscheme
    #    in Plasma will always copy over all color values from that colorscheme
    #    into the `kdeglobals` file.
    # 7. For any color it was unable to find a value for (which is all of them
    #    if the aforementioned XDG data or config file cannot be found), fall
    #    back to defaults. Defaults may come from a variety of places (app
    #    itself, QtPallete, Breeze) and it's hard to predict which it'll be.

    modules.kdeConfig.kdeglobals = lib.mkMerge [
      { UiSettings.ColorScheme = "CatppuccinMochaBlue"; }
      ( 
        # To deal with the issue described above in step 6:
        builtins.readFile
       "${catppuccin-kde-mocha-blue}/share/color-schemes/CatppuccinMochaBlue.colors"
      )
    ];

    xdg.configFile = let
      toStr = builtins.toString;
      toINI = lib.generators.toINI {};
      confDir = v: "qt${toStr v}ct";
      confFile = v: "${confDir v}/qt${toStr v}ct.conf";
      colorsFile = v: "${confDir v}/colors/catppuccin-mocha-blue-breeze.conf";
      absColorsFile = v: "${config.xdg.configHome}/${colorsFile v}";

      # qt6ct expects slightly different config values from qt5ct for color
      # schemes. In the case of colorschemes (assuming we aim for a consistent
      # coloring between both versions) these differences are only at the end.
      # Not entirely sure what changes but I have checked that this is also
      # consistent with what happens in Breeze and Catppuccin-KDE and as far as
      # I can tell the theme is consist between qt5 and qt6 apps, so whatever.
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

      # qt5ct and qt6ct config values that are exactly the same between both.
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
  };
}
