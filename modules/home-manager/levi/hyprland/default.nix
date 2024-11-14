{ config, lib, ... }:

let 
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  imports = [
    ./keywords.nix
    ./variables.nix
  ];

  options.modules.home-manager.levi.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
    useDunst = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
      Enable and autostart Dunst messaging daemon.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };

    modules.home-manager.levi.dunst.enable = cfg.useDunst;
  };
}
