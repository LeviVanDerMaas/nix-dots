{ pkgs, lib, config, ... }:
let
  cfg = config.modules.nixos.ddcutil;
  toStr = builtins.toString;
  brightnessScript = import ./brightnessScript.nix { inherit pkgs; inherit config; };
in
{
  options.modules.nixos.ddcutil = {
    enable = lib.mkEnableOption "Enable ddcutil service.";
    numMonitors = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Number of monitors to control with ddcutil.";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      ddcutil
    ];
    environment.shellAliases = {
      br = brightnessScript;
    };
  };
}
