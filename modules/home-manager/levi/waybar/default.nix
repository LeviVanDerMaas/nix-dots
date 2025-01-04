{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home-manager.levi.waybar;
in
{
  options.modules.home-manager.levi.waybar = {
    enable = lib.mkEnableOption ''
      Waybar
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ waybar pavucontrol ];
    xdg.configFile.waybar = {
      source = ./config;
      target = "waybar/config";
    };
    xdg.configFile.waybar-style = {
      source = ./style.css;
      target = "waybar/style.css";
    };
  };
}
