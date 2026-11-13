{ pkgs, config,  lib, ... }:

let
  cfg = config.modules.gaming.gamescope;
in
{
  options.modules.gaming.gamescope = {
    enable = lib.mkEnableOption ''Enable custom gamescope module'';
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
    };
  };
}
