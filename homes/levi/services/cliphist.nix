{ pkgs, lib, config, ... }:

let
  cfg = config.modules.cliphist;
in
{
  options.modules.cliphist = {
    enable = lib.mkEnableOption "Enable cliphist";
    targetDesktops = lib.mkOption {
      type = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
      default = [];
      description = ''Start cliphist only when XDG_CURRENT_DESKTOP matches one of these values'';
    };
  };
  config = lib.mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      allowImages = false; #WARNING: CHECK THIS
      extraOptions = [ "-max-items" "10" ];
    };
    modules.services.conditonSystemdServiceOnDE = { cliphist = cfg.targetDesktops; };
  };
}
