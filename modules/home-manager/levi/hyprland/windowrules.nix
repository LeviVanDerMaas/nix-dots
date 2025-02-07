{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
      windowrulev2 = [
        # Makes everything around ulauncher dim whenever it pops
        # up so that it appears as though it is in front of everything else.
        "dimaround, class:(ulauncher)"
      ];
    };
}
