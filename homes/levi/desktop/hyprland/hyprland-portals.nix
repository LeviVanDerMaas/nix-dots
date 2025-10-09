{ pkgs, ... }:

# Config XDG to use the kde portal specifically when picking files,
# and otherwise use the hyprland portal with fallback to gtk portal
# (gtk portal being DE-agnostic). This is because the gtk file picker
# sucks absolute ass and the KDE file picker works well outside of
# KDE especially when Dolphin is installed. Speaking of which, the
# extra deps that the kde portal pullls in are neglible when we are also
# using Dolphin, so it's totally worth it.
{
  xdg.portal = {
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-gtk 
      kdePackages.xdg-desktop-portal-kde
    ];
    config.hyprland = { # Portal spec enforces lower-case config names.
      default = "hyprland;gtk";
      "org.freedesktop.impl.portal.FileChooser" = "kde";
    };
  };

  # This helps persuade most gtk apps to actually respect portal config.
  # Seems like it's mainly gtk3 apps that otherwise have troulbe with portals.
  wayland.windowManager.hyprland.settings.env = [ "GTK_USE_PORTAL,1" ];
}
