{ lib, config, ... }:
let
  cfg = config.common.backlight;
in
{
  options.common.backlight = {
    enable = lib.mkEnableOption "Enable backlight control";
  };

  config = lib.mkIf cfg.enable {
    programs.light = {
      enable = true;
      brightnessKeys = {
        enable = true;
        step = 5;
      };
    };
  };
}
