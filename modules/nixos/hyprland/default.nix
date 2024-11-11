{ pkgs, lib, config, ... }:

let
  cfg = config.modules.nixos.hyprland;
in
{
  options.modules.nixos.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland system module. Use Home-Mamanger module for configuration.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    # Set desktop portal, needed for Hyprland.
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
