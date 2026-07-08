{ flake-inputs, pkgs, lib, fns, config, osConfig ? {}, ... }:

let
  cfg = config.modules.noctalia;

  systemDefaultMonospaceFont = builtins.head (
    config.fonts.fontconfig.defaultFonts.monospace or []
    ++ osConfig.fonts.fontconfig.defaultFonts.monospace or []
    ++ [ "sans-serif" ] # noctalia's default
  );
in
{
  imports = [ flake-inputs.noctalia.homeModules.default ];

  options.modules.noctalia = {
    enable = lib.mkEnableOption ''Install and configure Noctalia, a Wayland compositor shell.'';
  };

  config = lib.mkIf cfg.enable {
    # Little hack to make the notification history not persist between restarts
    # xdg.cacheFile."noctalia/notifications.json" = {
    #   force = true;
    #   text = lib.toJSON { notifications = []; };
    # };

    programs.noctalia = {
      enable = true;

      customPalettes.CatppuccinMochaBlue.dark = {
        mError = "#f38ba8";
        mHover = "#b4befe";
        mOnError = "#11111b";
        mOnHover = "#11111b";
        mOnPrimary = "#11111b";
        mOnSecondary = "#11111b";
        mOnSurface = "#cdd6f4";
        mOnSurfaceVariant = "#a3b4eb";
        mOnTertiary = "#11111b";
        mOutline = "#4c4f69";
        mPrimary = "#89b4fa";
        mSecondary = "#cba6f7";
        mShadow = "#11111b";
        mSurface = "#1e1e2e";
        mSurfaceVariant = "#313244";
        mTertiary = "#b4befe";
        terminal = {}; # This one can be empty, but not missing.
      };
      settings.theme = {
        custom_palette = "CatppuccinMochaBlue";
        mode = "dark";
        source = "custom";
        templates = {
          enable_builtin_templates = false;
          enable_community_templates = false;
        };
      };

    # You can use the following command to export all explictly set config values to your clipboard
    # nix eval --impure --raw --expr "with import <nixpkgs> {}; lib.generators.toPretty {} (builtins.fromTOML ''$(noctalia config export)'')" | wl-copy
      settings = {
        bar = {
          Main = {
            # Widgets
            start = [
              "launcher"
              "tray"
              "active_window"
              "media"
            ];
            center = [
              "workspaces"
            ];
            end = [
              "lock_keys"
              "notifications"
              "brightness"
              "volume"
              "bluetooth"
              "network"
              "Spacer"
              "battery"
              "clock"
              "control-center"
            ];
            # Bar style and layout settings
            background_opacity = 0.93;
            capsule = true;
            capsule_padding = 7.0;
            margin_edge = 4;
            margin_ends = 4;
            padding = 5;
            panel_overlap = 0;
            radius = 15;
            scale = 0.96;
            thickness = 32;
          };
        };

        brightness = {
          enable_ddcutil = true;
        };

        control_center = {
          shortcuts = [
            {
              type = "wifi";
            }
            {
              type = "bluetooth";
            }
            {
              type = "notification";
            }
            {
              type = "nightlight";
            }
            {
              type = "clipboard";
            }
            {
              type = "session";
            }
          ];
          sidebar = "full";
          sidebar_section = "none";
        };

        shell = {
          launcher = {
            categories = false;
          };
          panel = {
            clipboard_placement = "attached";
            open_near_click_clipboard = true;
            open_near_click_control_center = true;
          };
          settings_show_advanced = true;
          shadow = {
            direction = "center";
          };
        };

        widget = {
          Spacer = {
            type = "spacer";
            length = 26;
          };
          active_window = {
            icon_size = 20;
            max_length = 145;
            min_length = 145;
            title_scroll = "on_hover";
          };
          battery = {
            display_mode = "graphic";
          };
          brightness = {
            font_family = systemDefaultMonospaceFont;
          };
          bluetooth = {
            hide_when_no_connected_device = true;
          };
          clock = {
            capsule = true;
            capsule_padding = 10;
            format = "%a, %d %b ⧸ %R";
            tooltip_format = "%x ⧸ %X";
          };
          control-center = {
            capsule = true;
            capsule_padding = 2;
            custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            custom_image_colorize = true;
            scale = 1.3;
          };
          launcher = {
            glyph = "rocket";
          };
          lock_keys = {
            hide_when_off = true;
            icon_color = "error";
            show_scroll_lock = true;
          };
          media = {
            hide_when_no_media = true;
            max_length = 400;
            min_length = 145;
            title_scroll = "on_hover";
          };
          network = {
            show_label = false;
          };
          notifications = {
            hide_when_no_unread = true;
          };
          volume = {
            font_family = systemDefaultMonospaceFont;
          };
          workspaces = {
            active_pill_size = 2.0;
            display = "name";
            focused_output_only = true;
            font_family = systemDefaultMonospaceFont;
            font_weight = 700;
            labels_only_when_occupied = true;
            max_label_chars = 10;
          };
        };

        desktop_widgets = {
          enabled = false;
        };

        lockscreen = {
          enabled = false;
        };
        lockscreen_widgets = {
          enabled = false;
        };

        osd = {
          kinds = {
            media = false;
          };
        };

        wallpaper = {
          enabled = false;
        };

        weather = {
          enabled = false;
        };
      };
    };
  };
}

