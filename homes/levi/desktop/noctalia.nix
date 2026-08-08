{ flake-inputs, pkgs, lib, config, osConfig ? {}, ... }:

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

        notification = {
          history_retention_hours = 24;
        };
        
        shell = {
          setup_wizard_enabled = false;
          settings_show_advanced = true;
          clipboard_history_max_entries = 30;

          animation = {
            speed = 1.5;
          };

          shadow = {
            alpha = 1;
            direction = "down";
          };

          panel = {
            open_near_click_control_center = true;
          };
          launcher = {
            categories = false;
          };

          session.actions = let hyprshutdown = config.modules.hyprshutdown; in [
            {
              action = "suspend";
              countdown_seconds = 1.0;
              shortcut = "1";
            }
            {
              action = "logout";
              command = hyprshutdown.logoutCommand;
              countdown_seconds = 3.0;
              shortcut = "2";
            }
            {
              action = "reboot";
              command = hyprshutdown.rebootCommand;
              countdown_seconds = 3.0;
              shortcut = "3";
            }
            {
              action = "shutdown";
              command = hyprshutdown.shutdownCommand;
              countdown_seconds = 3.0;
              shortcut = "4";
              variant = "destructive";
            }
          ];
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
            capsule = true;
            capsule_padding = 8;
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
            capsule = true;
            capsule_padding = 8;
          };
          network = {
            show_label = false;
          };
          notifications = {
            hide_when_no_unread = true;
          };
          tray = {
            drawer = true;
            hidden = [ "Discord" ];
            # Once the option to hide passive items comes back in v5, adding this rule
            # together with hiding passive should make udiskie so that it only shows when an usb is inserted.
            # pinned = [ "udiskie" ];
          };
          volume = {
            font_family = systemDefaultMonospaceFont;
            mute_color = "on_surface_variant";
          };
          workspaces = {
            active_pill_size = 2.0;
            focused_output_only = true;
            font_family = systemDefaultMonospaceFont;
            font_weight = 700;
            label_source = "name";
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
            privacy = false;
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

