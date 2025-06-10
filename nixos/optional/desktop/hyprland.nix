{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland system module. Enabling this module will also set up some things
      on the system-side which we can use on the Home-Manager side to add DE
      features to Hyprland. 
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    # Hyprland has its own xdg-desktop-portal-hyprland that the NixOS module
    # automatically installs. However, it does not implement a file picker and
    # is still in development, so Hyprland recommends gtk portal as fallback.
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      config.Hyprland = {
        default = "hyprland;gtk";
      };
    };

    # Needed to let udiskie automount when installed on home-manager side.
    modules.udisks2.enable = true;
  };
}
