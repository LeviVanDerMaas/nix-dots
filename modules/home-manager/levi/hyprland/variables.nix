{ config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    general = {
      border_size = 1;
      gaps_in = 5;
      gaps_out = 10;
      "col.active_border" = "rgba(4e4075ee) rgba(382235ee)";
      "col.inactive_border" = "rgba(595959aa)";
      layout = "dwindle";
    };

    input = {
      kb_layout = "us";
      kb_options = "caps:escape, compose:ralt";
      repeat_rate = 60;
      repeat_delay = 600;

      follow_mouse = 1;
    };

    # per device input can be done as follows
    # device = [
    #   {
    #     name = "name";
    #     someInputOption1 = "...";
    #   }
    #   ...
    # ];

    dwindle = {
      preserve_split = true; # If false, resizing windows can change splits.
      smart_split = true; # Splits into the direction of the mouse

    };

    decoration = {
      rounding = 10;

      blur = {
        enabled = true;
        size = 3;
      };

      # shadow = {
      #   enabled = true;
      # };
    };

    animations = {
      enabled = true;

      bezier = [
        "standardBezier, 0.05, 0.9, 0.1, 1.05"
      ];

      animation = [
        "windows, 1, 4, standardBezier,"
        "windowsOut, 1, 4, default, popin 80%"
        "border, 1, 5, default"
        "borderangle, 1, 4, default"
        "fade, 1, 4, default"
        "workspaces, 1, 4, default"
      ];
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };

  };
}
