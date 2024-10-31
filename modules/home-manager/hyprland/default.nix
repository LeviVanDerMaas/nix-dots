{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption "Hyprland Home-Manager Module";
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
