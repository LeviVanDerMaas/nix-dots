{ pkgs, config, lib, ... }:

let 
  cfg = config.hyprland;
in
{
  options = {
    hyprland.enable = lib.mkEnableOption "Hyprland Home-Manager Module";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };

    qt.enable = true;
    qt.style.name = "breeze-dark";

    services.dunst.enable = true;
  };
}
