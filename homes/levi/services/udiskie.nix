{ config, lib, ... }:

let
  cfg = config.modules.udiskie;
in
{
  options.modules.udiskie = {
    enable = lib.mkEnableOption ''
      GUI front-end for udisks2. Can be used for things like auto-mounting.
      `services.udisks2.enable` must be true on the system config side, otherwise
      this service cannot run effectively.
    '';
    targetDesktops = lib.mkOption {
      type = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
      default = [];
      description = ''Start udiskie only when XDG_CURRENT_DESKTOP matches one of these values'';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udiskie = {
      enable = true;
      automount = true;
    };
    modules.services.conditonSystemdServiceOnDE = { udiskie = cfg.targetDesktops; };
  };
}
