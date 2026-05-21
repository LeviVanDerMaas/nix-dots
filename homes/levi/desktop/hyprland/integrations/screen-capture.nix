{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hyprland;
  grimPre = "grimblast --notify --freeze";
in
lib.mkIf cfg.enable {
  home.packages = with pkgs; [
    grimblast # Official Hyprland screenshot util (nix wraps this with all of Hyprland btw)
    hyprpicker # Official color picker, also dep for grimblast's --freeze flag.
    wl-clipboard #  Dep for both, nix wraps this in already, but this is not technically a required dep so eh.
  ];

  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    hl.bind("PRINT", DIS.exec_cmd("${grimPre} copy output"))
    hl.bind("SHIFT + PRINT", DIS.exec_cmd("${grimPre} copy area"))
    hl.bind("CTRL + PRINT", DIS.exec_cmd("${grimPre} copy screen"))
    hl.bind("ALT + PRINT", DIS.exec_cmd("hyprpicker -anf hex"))
  '';
}
