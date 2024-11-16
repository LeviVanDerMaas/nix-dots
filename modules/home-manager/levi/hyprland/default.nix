{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  imports = [
    ./keywords.nix
    ./variables.nix
    ./hyprpaper.nix
  ];

  options.modules.home-manager.levi.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Just the list that you would pass into 
        `wayland.windowManager.hyprland.settings.monitor`.
        Reason it is a seperate model is because this is very much
        system-dependent, so this lets you configure it at a per-system
        level.
      '';
    };
    integrateDunst = lib.mkOption {
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
      settings = {
        monitor = cfg.monitors;
      };
    };

    modules.home-manager.levi = {
      dunst.enable = cfg.integrateDunst;
    };

    home.packages = with pkgs; [
      grimblast
      hyprpolkitagent
      ulauncher
    ];
  };
}
