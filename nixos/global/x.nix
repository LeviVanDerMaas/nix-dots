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
}
