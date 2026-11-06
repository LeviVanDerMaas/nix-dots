{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    modules.udiskie = {
      enable = true;
      targetDesktops = "Hyprland";
    };
  }; 
}
