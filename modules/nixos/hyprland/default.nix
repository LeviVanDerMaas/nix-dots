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
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-kde ];
      config.hyprland = {
        default = "hyprland;gtk";
        "org.freedesktop.impl.portal.FileChooser" = "kde";
      };
    };

    environment.systemPackages = with pkgs; [
      kdePackages.kdialog
    ];

    # Needed to let udiskie automount when installed on home-manager side.
    modules.nixos.udisks2.enable = true;
  };
}
