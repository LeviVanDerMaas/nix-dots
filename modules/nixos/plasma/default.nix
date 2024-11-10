{ lib, config, ... }:

let
  cfg = config.modules.nixos.plasma;
in
{
  options.modules.nixos.plasma = {
    enable = lib.mkEnableOption "Install and configure Plasma";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
