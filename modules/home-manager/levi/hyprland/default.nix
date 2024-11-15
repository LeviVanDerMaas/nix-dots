{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  imports = [
    ./keywords.nix
    ./variables.nix
    ./hyprpaper.nix
    ./flameshotIntegration.nix
  ];

  options.modules.home-manager.levi.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
    integrateDunst = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable and autostart Dunst messaging daemon.
      '';
    };
    integrateFlameshot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable Flameshot screenshot tool and attempt to integrate with
        Hyprland. This tool was originally created for X11 so experience
        may be suboptimal.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };

    modules.home-manager.levi = {
      dunst.enable = cfg.integrateDunst;
      flameshot.enable = cfg.integrateFlameshot;
    };

    home.packages = with pkgs; [
      hyprpolkitagent
      ulauncher
    ];
  };
}
