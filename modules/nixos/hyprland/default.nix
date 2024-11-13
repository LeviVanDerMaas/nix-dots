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

    # I added these options once but I dont know why and it seems to
    # no longer be necessary.
    # xdg.portal.enable = true;
    # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
