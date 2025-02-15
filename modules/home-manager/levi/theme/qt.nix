{ pkgs, overlays, ... }:

# NOTE: BREEZE RELIES ON .config/kdeglobals TO TELL IT WHAT COLORS TO ACTUALLY USE.
# IN FACT, THE ONLY REALLY IMPORANT THING THAT SELECTING "BREEZE DARK" AS THEME IN
# PLASMA DOES IS SWITCHING THE RGB VALUES IN THAT FILE TO THOSE OF BREEZE DARK.
# THIS ALSO MEANS YOU CAN COMPLETY CUSTOMIZE BREEZE'S COLORS TO YOUR LIKING.

{
  # The HM qt module is not designed with installing Breeze6 in mind,
  # so we should handle installation of Breeze 6 (and 5) ourselves.
  qt = {
    enable = true;
  };

  home.packages = with pkgs; [
    # The HM qt module does not actually seem to ship wayland support by default.
    libsForQt5.qtwayland
    kdePackages.qtwayland

    # Install both breeze5 and breeze6 since qt5 is still very commonplace.
    # Use the qt5 output instead of libsForQt5 to prevent package collisions.
    kdePackages.breeze
    kdePackages.breeze.qt5

    # plasma-integration should make most KDE-native apps render correctly.
    # and also make some aspects of Breeze look nicer.
    kdePackages.plasma-integration
    kdePackages.plasma-integration.qt5
  ];



  # Breeze requires platformtheme to be set to `kde` in order to pick up on
  # your config in .config/kdeglobals. The one downside to this is that setting
  # platformtheme to `kde` will cause some KDE apps to ignore your xdg-portal
  # config and just go for the kde-portal (and fail if not present). In
  # practice this does not cause much issue if you have the kde portal
  # installed beyond getting some janky-looking (but still serviceable) file
  # pickers or app selectors. Trade-off for not being stuck with Breeze light.
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "kde";
    QT_STYLE_OVRRIDE = "breeze";
  };
}
