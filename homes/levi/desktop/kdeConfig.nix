{ pkgs, config, lib, ... }:

# NOTE: KDE seems to handle duplicate sections in the same file just fine
# and merges them internally (for duplicate keys, the last value is used).
# But if we ever get any weirdness, that might just be caused by that.
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
        A module to manually configure KDE-related config files. We would want to
        be able to disable this module as a whole in cases where we also
        install Plasma on the device, because Plasma can freak out pretty hard 
        if it does not have proper control of KDE-related config files.
      '';
    };

    kdeglobals = lib.mkOption {
      type = with lib.types; coercedTo (attrsOf str) toINI lines;
      default = null;
      description = ''
        This file primarily stores information that should be applied "globally"
        throughout the DE. For example, Breeze and KDE-native apps read color scheme
        info from this fileAnd KDE-native apps find the default terminal to use here.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile = {
      ${if cfg.kdeglobals != null then "kdeglobals" else null}.text = cfg.kdeglobals;
    };
  };
}
