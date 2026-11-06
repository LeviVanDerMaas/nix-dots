{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  modules.kdeConfig.xdg-desktop-portal-kde.enable = true;
  xdg.portal.config.hyprland = {
    default = "hyprland;kde;gtk";
  };

  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    -- Coaxes *most* gtk3 apps to use xdg portals, because this is not the default for gtk3.
    hl.env("GTK_USE_PORTAL", "1")
  '';
}
