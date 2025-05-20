{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
      windowrule = [
        "dimaround, class:(ulauncher)"
      ];
    };
}
