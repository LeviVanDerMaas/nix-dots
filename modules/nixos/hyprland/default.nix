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

    # Hyprland has its own xdg-desktop-portal-hyprland that the NixOS module
    # automatically installs. However, it does not implement a file picker and
    # is still in development, so Hyprland represent gtk portal as fallback.
    # We also add the kde portal because some KDE apps (Dolphin) will ignore
    # portal spec under certain circumstances and only look for kde portal when
    # not running under a DE.
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-kde ];
      config.hyprland = {
        default = "hyprland;gtk";
      };
    };

    # Needed to let udiskie automount when installed on home-manager side.
    modules.nixos.udisks2.enable = true;
  };
}
