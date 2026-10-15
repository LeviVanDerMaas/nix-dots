{ pkgs, config, lib, ... }:

# NOTE: KDE config files seems to handle duplicate sections in the same file
# just fine and merge them internally (for duplicate keys, the last value is
# used). But if we ever get any weirdness, that might just be caused by that.
let
  cfg = config.modules.kdeConfig;
  toINI = lib.generators.toINI {};
in
{
  options.modules.kdeConfig = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        A module to manage installation and configuration of KDE related
        software and services. This is because using things from KDE outside of
        Plasma generally requires some extra tinkering to make them work
        properly and/or manually configuring files directly instead of using
        KDE's "Settings" app, which this module takes care of.

        You should usually keep this `enable` option on, but it can be disabled to
        cripple the whole module. This is mainly useful for diagnosing problems and/or
        when you experience issues when using this module while also having/using
        Plasma as a whole; Plasma generally handles not being in control of a config
        file or unexpected values gracefully, but there's always the chance of wonkiness.
      '';
    };
    kdeglobals = lib.mkOption {
      type = with lib.types; nullOr (coercedTo (attrsOf str) toINI lines);
      default = null;
      description = ''
        Configuration to write to `~/.config/kdeglobals.` This file primarily
        stores information that should be applied "globally" throughout
        Plasma/KDE-applications. For example, the Breeze theme (Qt) and
        KDE-native apps read color scheme info from this file and KDE-native
        apps find the default terminal to use here.
      '';
    };
    enforceQtPlatformthemeInPlasma = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        On starting a session in Plasma, sets `QT_QPA_PLATFORMTHEME=kde` for the full session.
        This ensures that while inside KDE, KDE manages Qt apps.
      '';
    };
    xdg-desktop-portal-kde = {
      enable = lib.mkEnableOption ''
        Install `kdePackages.xdg-desktop-portal-kde` and set some additional
        configuration to make it work (mostly) correctly outside of Plasma.
      '';
      forceKdePlatformTheme = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Forces `QT_QPA_PLATFORMTHEME=kde` in the portal's systemd service environment.
          This fixes some issues where the portal depends on the presence of KDE's Qt
          platformtheme to construct and style dialogs properly when certain parameters are passed,
          and will fall back to native Qt dialogs without it (e.g. the File Picker portal will
          fall back to the native Qt one if `directory = true` is passed when invoking the portal,
          though it works fine without any parameters).

          DOWNSIDE: The Qt styling for portal dialogs now is managed by the KDE platformtheme too
          and ignores the global Qt styling. Though, this is not an issue if you are already using
          Breeze as your Qt theme globally, provided you have it configured properly.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      xdg.configFile = {
        kdeglobals.text = lib.mkIf (cfg.kdeglobals != null) cfg.kdeglobals;
        "plasma-workspace/env/enforcePlatformtheme.sh".text =
          lib.mkIf cfg.enforceQtPlatformthemeInPlasma "export QT_QPA_PLATFORMTHEME=kde";
        };
    }

    (lib.mkIf cfg.xdg-desktop-portal-kde.enable {
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      };
      home.packages = [
        # Needed because even when using a different platformtheme, the portal *might*
        # break without this being present depending on Qt configuration.
        # It is also needed for the below systemd service envvar hack to work.
        pkgs.kdePackages.plasma-integration
      ];
      xdg.configFile."systemd/user/plasma-xdg-desktop-portal-kde.service.d/force_qt_platformtheme_kde.conf".text =
        lib.mkIf cfg.xdg-desktop-portal-kde.forceKdePlatformTheme ''
          [Service]
          Environment=QT_QPA_PLATFORMTHEME=kde
        '';
      # systemd.user.services.plasma-xdg-desktop-portal-kde.Service.Environment =
      #   lib.mkIf cfg.xdg-desktop-portal-kde.forceKdePlatformTheme [
      #     "QT_QPA_PLATFORMTHEME=kde"
      #   ];
    })
  ]);
}
