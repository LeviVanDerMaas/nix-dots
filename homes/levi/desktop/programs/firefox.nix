# MANAGING AND CONVERTING FIREFOX CONFIGURATION PROFILES:
# Firefox stores most configuration on a per-profile basis (and profiles are
# stored on a per-system-user basis; one user can have multiple profiles).
# These profiles are described in .config/mozilla/firefox/profiles.ini. Should
# you want to convert an already existing profile into one that is managed by
# the below, it should be as simple as renaming the profile's directory to one
# of the profile names managed below here (at least, this actually seems to
# work very smoothly at first glance); this preserves any state up to that point.
#
# It seems the home-manager modules tries to be "additive" rather than
# "authorative" when it comes to configuration. It will only try to touch the
# files it needs to touch to accomplish its stuff, so it should still be
# possible to control firefox pretty freely without needing to mess around with
# the nix-config whenever you want to change a slight thing. There's also
# various "force" flags for some options that are off by default to prevent you
# from clobbering any stateful config by accident.
{ config, ... }:

{
  programs.firefox = {
    enable = true;
    # Explicitly set config path to modern default because our home.stateVersion uses legacy.
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    profiles.levi = {
      # Controls the profile's `user.js` file; on startup any values in here
      # are merged into the profile's prefs.js, which controls about:config values.
      # So, these are startup-defaults for about:config.
      settings = {
        # I'm sure eventually I will have to submit to the new theming, but
        # for now we'll do this. I hope when it's time, I at least have the
        # option to use square instead of round corners like in the old theme.
        "browser.nova.enabled" = false;
      };
    };
  };
}
