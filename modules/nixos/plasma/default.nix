# NOTE: issues I have encountered with Plasma thus far.
# - If the env var QT_QPA_PLATFORM is set to certain values, such as gtk2,
#   it will fail to start and error about being unable to find Qt elements.
# - The way Plasma is set up it really likes to take control over your theming when
#   in other DE's or WM's if you do not set certain things explictly.

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
