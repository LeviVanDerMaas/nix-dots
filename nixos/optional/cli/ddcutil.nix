{ pkgs, lib, config, ... }:
let
  cfg = config.modules.ddcutil;
in
{
  options.modules.ddcutil = {
    enable = lib.mkEnableOption ''
      Enable ddcutil service. This will also enable i2c support.
      By default a locally logged on user should be able to manipulate i2c
      devices when this is enabled, but in case it does not work, the user
      must be added to the group specified by `hardware.i2c.group` (default: "i2c").
    '';
    numMonitors = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Number of monitors to control with ddcutil.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ddcutil
    ];

    hardware.i2c.enable = true;

    environment.shellAliases = {
      br = let 
        ddcutil = "${pkgs.ddcutil}/bin/ddcutil";
      in pkgs.writeShellScript "ddcutilBrightnessScript" ''
        if [ $# -eq 1 ]; then
          for i in {1..${builtins.toString cfg.numMonitors}}; do
            ${ddcutil} -d $i setvcp x10 $1;
          done
        elif [ $# -eq 2 ]; then
          ${ddcutil} -d $1 setvcp x10 $2;
        else
          echo 'INCORRECT INPUT: Use either "<screen> <brightness>" or "<brightness>"'
        fi
      '';
    };
  };
}
