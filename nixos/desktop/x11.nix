{ pkgs, ... }:

{
  services.xserver = {
    enable = true;

    # The best way to find xkb layouts, variants, options, etc. that is actually
    # up-to-date and complete is to just go rummaging through xkb's bundled configuration
    # files e.g. ${pkgs.xkeyboard-config}. All "core" options should be findable
    # .../share/X11/xkb/rules/evdev.lst (or xml) but some additional options may be tucked
    # away in other files like evdex.extras.xml
    xkb = {
      layout = "us";
      variant = "altgr-weur"; # https://altgr-weur.eu/
      options = "caps:escape_shifted_capslock";
    };
  };

  # Set the "default" cursor of X11.
  # May wanna consider making a custom package that pulls just breeze cursors
  # instead of all of breeze, should we end up not using breeze as our theme
  # in the future.
  environment.systemPackages = with pkgs; [ kdePackages.breeze ];
  xdg.icons.fallbackCursorThemes = [ "breeze_cursors" ];
}
