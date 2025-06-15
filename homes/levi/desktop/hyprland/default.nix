{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  imports = [
    ./animations.nix
    ./binds.nix
    ./exec.nix
    ./hyprpaper.nix
    ./monitors.nix

    ./integrations
  ];

  options.modules.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
    extraEnv = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Extra values for the `env` keyword to be added to the config. May be useful for
        things like conditionally setting an envvar for a service that is managed
        differently between two devices sharing the same config.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      blueberry # simple bluetooth control
      hyprpolkitagent
      ulauncher
    ];

    modules = {
      dunst.enable = true;
      udiskie.enable = true; # for auto-mounting
      waybar.enable = true;
    };

    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.settings = {
      env = cfg.extraEnv;

      input = {
        kb_layout = "us";
        kb_options = "caps:escape, compose:sclk";
        repeat_rate = 60;
        repeat_delay = 600;
      };

      general = {
        border_size = 2;
        gaps_in = 5;
        gaps_out = 10;
        "col.active_border" = "rgba(701bbbee)";
        "col.inactive_border" = "rgba(35293dcc)";

        layout = "dwindle";
        no_focus_fallback = true;
      };

      dwindle = {
        preserve_split = true; # If false, resizing windows can change splits.
      };

      decoration = {
        rounding = 3;
        blur = {
          enabled = true;
          size = 3;
        };
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      windowrule = [
        "dimaround, class:(ulauncher)"
      ];
    };
  };
}
