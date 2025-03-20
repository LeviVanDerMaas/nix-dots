{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
      windowrulev2 = [
        "dimaround, class:(ulauncher)"
      ];
    };
}
