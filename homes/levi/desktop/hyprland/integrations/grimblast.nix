{ pkgs, config, lib, fns, ... }:

let
  cfg = config.modules.hyprland;

  grimblastPatched = pkgs.grimblast.overrideAttrs (old: {
    # This patch makes the script not fail if attemtping to save to a directory that doesn't exist,
    # but instead just creates the directory first. Try upstreaming this later.
    patches = (old.patches or []) ++ [ ./grimblast.patch ];
  });
in
lib.mkIf cfg.enable {
  home.packages = with pkgs; [
    (fns.checkPkgVersion grimblastPatched "0.1-unstable-2026-08-21") # Officially supported Hyprland screenshot util script (nix wraps this with all of Hyprland btw)
    hyprpicker # Official color picker, also dep for grimblast's --freeze flag.
    wl-clipboard # Dep for both, nix wraps this in already, but this is not technically a required dep so eh.
  ];

  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    hl.bind("PRINT", DIS.exec_cmd("grimblast copy output"))
    hl.bind("SUPER + PRINT", DIS.exec_cmd("grimblast --notify copysave output"))
    hl.bind("SHIFT + PRINT", DIS.exec_cmd("grimblast --freeze copy area"))
    hl.bind("CTRL + PRINT", DIS.exec_cmd("grimblast copy screen"))
    hl.bind("ALT + PRINT", DIS.exec_cmd("hyprpicker -anf hex"))
  '';
}
