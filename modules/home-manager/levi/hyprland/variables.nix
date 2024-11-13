{ config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    general = {

    };

    input = {
      kb_layout = "us";
      kb_option = "caps:escape, compose:ralt";
      repeat_rate = 60;
      repeat_delay = 600;

      follow_mouse = 1;
    };

    general = {
      border_size = 1;
      gaps_in = 5;
      gaps_out = 10;
      "col.active_border" = "rgba(4e4075ee) rgba(382235ee)";
      "col.inactive_border" = "rgba(595959aa)";
      layout = "dwindle";
    };
  };
}
