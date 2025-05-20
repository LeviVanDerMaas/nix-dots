{ lib, ... }:

let
  outskirts = "${../../../assets/wallpapers/outskirts.jpg}";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ outskirts ];
      wallpaper = [
        ", ${outskirts}"
      ];
    };
  };

  # The home-manager module for Hyprpaper will, when enabled, setup a systemd
  # service that automatically runs Hyprpaper in any wayland session, and can thus
  # interfere with other wallpaper utilities. Though the service is set up such that
  # it starts and stops alongside desktop session, its default setup makes it so that once
  # it has been started once, it will always restart when switching desktops even if the next
  # desktop does not meet startup conditions. These overrides ensure that the service starts only
  # in Hyprland, and will not restart when switching to a different desktop unless that desktop is
  # Hyprland again.
  systemd.user.services.hyprpaper = {
    Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=Hyprland";
    Service.Restart = lib.mkForce "on-failure"; 
  };
}
