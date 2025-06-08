{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  wayland.windowManager.hyprland.settings = {
    bezier = [
      "easeOutBob, 0.05, 1, 0.1, 1.03"
      "easeOut, 0.05, 1, 0.1, 1"

      "instant, 0, 10, 0, 10"
      "none, 1, -10, 1, -10"
    ];

    # Closing animations for windows will not work unless a fade animation is set,
    # otherwise the window will just instantly disappear (intended behavior, but undocumented
    # on the wiki). Might be fixed later https://github.com/hyprwm/Hyprland/issues/10352
    animation = [
      "windowsIn, 1, 3, easeOut, popin"
      "fadeIn, 1, 6, easeOut"
      "windowsOut, 1, 7, easeOut, popin"
      "fadeOut, 1, 7, easeOut"
      "windowsMove, 1, 3, easeOut, popin"

      "workspaces, 1, 3, easeOut, slide"
      "specialWorkspace, 1, 3, easeOut, slidevert"
      "layers, 1, 3, easeOut, slide"
    ];
  };
}
