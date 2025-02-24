{ pkgs, config, lib, ... }:

# NOTE: BREEZE RELIES ON .config/kdeglobals TO TELL IT WHAT COLORS TO ACTUALLY USE.
# IN FACT, THE ONLY REALLY IMPORANT THING THAT SELECTING "BREEZE DARK" AS THEME IN
# PLASMA DOES IS SWITCHING THE RGB VALUES IN THAT FILE TO THOSE OF BREEZE DARK.
# THIS ALSO MEANS YOU CAN COMPLETY CUSTOMIZE BREEZE'S COLORS TO YOUR LIKING.

let
  cfg = config.modules.home-manager.levi.kde.breeze.qt;
in
{
  options.modules.home-manager.levi.kde.breeze.qt = {
    enable = lib.mkEnableOption ''
      Installs and configures Breeze 5 and 6 for Qt applications. May not
      work/look correctly for all Qt apps, particulary KDE-native ones without
      setting `force`.
    '';
    force = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Forces Qt apps to use Breeze (if these apps use the "System default"
        for theming) and forces them to assume they are running under
        KDE/Plasma. The latter should fix most issues where applications will
        only partially apply the colors set in XDG_CONFIG_HOME/kdeglobals and
        fall back to Breeze Light or Fusion for other UI elements, but can
        potentially cause issues for Qt apps that are intended to run under a
        different platform. This may also cause some functions of KDE-native apps
        to ignore XDG config and always assume KDE-specific config; e.g. when
        opening xdg-portal some KDE apps will only look for xdg-portal-kde and fail 
        without it, ignoring any portal config the user may have set up.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # The HM qt module is not designed with installing Breeze6 in mind,
    # so we should handle installation of Breeze 6 (and 5) ourselves.
    qt = {
      enable = true;
    };

    home.packages = with pkgs.kdePackages; [
      # Install both breeze5 and breeze6 since qt5 is still very commonplace.
      # Use the qt5 output instead of libsForQt5 to prevent package collisions.
      breeze
      breeze.qt5

      # plasma-integration should make most KDE-native apps render correctly.
      # and also make some aspects of Breeze look nicer.
      plasma-integration
      plasma-integration.qt5
    ];

    # In practice this does not cause much issue if you have the kde portal
    # installed beyond getting some janky-looking (but still serviceable) file
    # pickers or app selectors. Trade-off for not being stuck with Breeze light.
    home.sessionVariables = lib.mkIf cfg.force {
      QT_QPA_PLATFORMTHEME = "kde";
      QT_STYLE_OVRRIDE = "breeze";
    };
  };
}
