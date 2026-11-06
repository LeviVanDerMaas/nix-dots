{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    modules.cliphist = {
      enable = true;
      targetDesktops = "Hyprland";
    };
  }; 
}
