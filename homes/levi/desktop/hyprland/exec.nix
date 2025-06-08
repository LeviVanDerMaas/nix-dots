{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
      exec-once = [
        # Desktop Utilities
        "systemctl --user start hyprpolkitagent"
        "${pkgs.ulauncher}/bin/ulauncher --no-window-shadow --hide-window"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.dunst}/bin/dunst"
      ];
    };
}
