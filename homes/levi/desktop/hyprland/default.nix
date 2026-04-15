{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  imports = [
    ./animations.nix
    ./binds.nix
    ./hyprland-portals.nix
    ./hyprpaper.nix
    ./hyprpolkitagent.nix
    ./hyprshutdown.nix
    ./hyprtoolkit.nix
    ./monitors.nix
    ./windowrules.nix

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
    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.settings = {
      env = [
        # Special NIXOS var makes most Electron and CEF apps use wayland by default.
        "NIXOS_OZONE_WL,1"
      ] ++ cfg.extraEnv;

      input = {
        kb_layout = "us";
        kb_variant = "altgr-weur"; # https://altgr-weur.eu/
        kb_options = "caps:escape_shifted_capslock";
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
        preserve_split = true;
        precise_mouse_move = true; # Smart split but only when using the mouse
      };

      decoration = {
        rounding = 3;
        blur = {
          enabled = true;
          size = 3;
        };
      };

      binds = {
        hide_special_on_workspace_change = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
    };
  };
}
