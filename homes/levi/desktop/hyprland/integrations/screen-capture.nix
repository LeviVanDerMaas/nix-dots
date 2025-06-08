{ pkgs, config, lib, ... }:

let
  hyprlandEnabled = config.modules.hyprland.enable;
  grimPre = "grimblast --notify --freeze";
in
lib.mkIf hyprlandEnabled {
  home.packages = with pkgs; [
    grimblast # Official Hyprland screenshot util (nix wraps this with all of Hyprland btw)
    hyprpicker # Official color picker, also dep for grimblast's --freeze flag.
    wl-clipboard #  Dep for both, nix wraps this in already, but this is not technically a required dep so eh.
  ];

  wayland.windowManager.hyprland.settings = {
      bind = [
        ", PRINT, exec, ${grimPre} copy output"
        "SHIFT, PRINT, exec, ${grimPre} copy area"
        "CTRL, PRINT, exec, ${grimPre} copy screen"

        "$ALT, PRINT, exec, hyprpicker -anf hex"
      ];
  };
}
