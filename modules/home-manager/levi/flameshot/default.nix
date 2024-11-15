{ config, lib, ... }:

let 
  cfg = config.modules.home-manager.levi.flameshot;
in
{
  options.modules.home-manager.levi.flameshot = {
    enable = lib.mkEnableOption ''
      Enable Flameshot, an X11 screenshot tool.
    '';
  };

  config = lib.mkIf cfg.enable {
    services.flameshot.enable = true;
  };
}
