{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
      exec-once = [
        # Desktop Utilities
        "systemctl --user start hyprpolkitagent"
        "${pkgs.ulauncher}/bin/ulauncher --no-window-shadow --hide-window"
        "${pkgs.waybar}/bin/waybar"

        # Ordinary applications
        "${pkgs.discord}/bin/discord"
      ] ++
      lib.optionals cfg.integrateDunst [ "${pkgs.dunst}/bin/dunst" ];
    };
}
