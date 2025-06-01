{ pkgs, ... }:

# NOTE: BREEZE RELIES ON .config/kdeglobals TO TELL IT WHAT COLORS TO ACTUALLY USE.
# IN FACT, THE ONLY REALLY IMPORANT THING THAT SELECTING "BREEZE DARK" AS THEME IN
# PLASMA DOES IS SWITCHING THE RGB VALUES IN THAT FILE TO THOSE OF BREEZE DARK.
# THIS ALSO MEANS YOU CAN COMPLETY CUSTOMIZE BREEZE'S COLORS TO YOUR LIKING.
{
  # Do not use the qt submodule to install Breeze, it does not install Breeze 6,
  # we should handle installing breeze 6 (and 5) ourselves.
  qt = {
    enable = true;
  };


  home.packages = with pkgs.kdePackages; [
    # The HM qt module does not actually seem to ship wayland support by default.
    qtwayland # For Breeze 6
    pkgs.libsForQt5.qtwayland # For Breeze 5

    # Install both breeze5 and breeze6 since qt5 is still very commonplace.
    # Use the qt5 output instead of libsForQt5 to prevent package collisions.
    breeze
    breeze.qt5

    # plasma-integration should make Breeze work and look better in some places,
    # and especially with KDE native apps.
    plasma-integration
    plasma-integration.qt5
  ];

  # Force Qt apps to actually use Breeze (if these apps are set to use "system
  # default" theme) and force them to assume they are runnng under KDE/Plasma.
  # This fixes some instances where Breeze might not be applied entirely
  # properly, and the latter should also fix the issue where some applications
  # will not or only partially read from KDE globals. This has the potential to
  # cause issues for Qt apps specifically designed for running under a
  # different platform, and it may also cause some functions of KDE-native apps
  # to ignore XDG config and just use the KDE-specific config (e.g. it will
  # ignore what is set in XDG-desktop portal and only look for the KDE portal).
  # In practice this does not cause much issue if you have the kde portal
  # installed beyond getting some janky-looking (but still serviceable) file
  # pickers or app selectors. Trade-off for not being stuck with Breeze
  # defaults.
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "kde";
    QT_STYLE_OVRRIDE = "breeze";
  };
}
