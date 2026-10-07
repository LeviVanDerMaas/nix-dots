{ pkgs, lib, config, ... }:
let
  cfg = config.modules.brightnessctl;
in
{
  options.modules.brightnessctl = {
    enable = lib.mkEnableOption 
      "Enable brightnessctl, tool for controlling device brightness.";
    brightnessKeys = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Configure `services.actkbd` to set up system-level bindings to control
          the brightness with keyboard brightness keys. This means you can use
          the brightness keys even while outside any desktop enviornment.
        '';
      };
      step = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Percentage value by which to change brightness";
      };
      minBrightness = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = ''
          Prevents brightness from being set below this absolute value. Since
          these are absolute values, a value of "1" is very likely
          indistinguishable from 0% brightness. You can use "brightnessctl max"
          to get the max value of the screen's brightness, then divide that by 100 to
          get the value corresponding to a 1% brightness.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ brightnessctl ];

    services.actkbd = lib.mkIf cfg.brightnessKeys.enable {
      enable = true;
      bindings =
        let
          brightnessctl = "${lib.getExe pkgs.brightnessctl}";
          step = toString cfg.brightnessKeys.step;
          minBrightness = toString cfg.brightnessKeys.minBrightness;
        in
        [
          {
            keys = [ 224 ];
            events = [ "key" "rep" ];
            command = "${brightnessctl} -n${minBrightness} set ${step}%-";
          }
          {
            keys = [ 225 ];
            events = [ "key" "rep" ];
            command = "${brightnessctl} set ${step}%+";
          }
        ];
    };
  };
}
