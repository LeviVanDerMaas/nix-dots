{ pkgs, config, lib, ... }:

let
  cfg = config.modules.kde;
in
{
  options.modules.kde = { 
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        A module to manually configure KDE-related settings. We would want to
        be able to disable this module as a whole in cases where we also
        install Plasma on the device, because Plasma can freak out pretty hard 
        if it does not have proper control of KDE-related config files.
      '';
    };

    kdeglobals = lib.mkOption {
      type = lib.types.attrs;
      default = null;
      description = ''
        Uses `lib.generators.toINI` to generate a kde configuration file that
        is symlinked to `kdeglobals` inside the XDG configuration home. Do NOT
        enable this module and set this when your system is running Plasma, this
        can cause issues including inability to boot the DE properly.

        Configuring this can be useful when running KDE applications or the
        Breeze theme outside of Plasma because some of their features rely on
        settings defined in this file (e.g. custom coloring in Breeze partially
        relies on values defined here, applications like Dolphin read the
        default terminal from this file).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile = {
      ${if cfg.kdeglobals != null then "kdeglobals" else null}.text = 
        lib.generators.toINI {} cfg.kdeglobals;
    };
  };
}
