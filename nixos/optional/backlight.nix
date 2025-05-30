{ lib, config, ... }:
let
  cfg = config.modules.backlight;
in
{
  options.modules.backlight = {
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
