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
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile = {
      kdeglobals.text = lib.mkIf (cfg.kdeglobals != null) cfg.kdeglobals;
      "plasma-workspace/env/enforcePlatformtheme.sh".text =
        lib.mkIf cfg.enforceQtPlatformthemeInPlasma "export QT_QPA_PLATFORMTHEME=kde";
    };
  };
}
