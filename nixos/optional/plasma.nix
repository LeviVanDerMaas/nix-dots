# NOTE: issues I have encountered with Plasma thus far.
# - If the env var QT_QPA_PLATFORM is set to certain values, such as gtk2,
#   it will fail to start and error about being unable to find Qt elements.
# - The way Plasma is set up it really likes to take control over your theming when
#   in other DE's or WM's if you do not set certain things explictly.

{ pkgs, lib, config, ... }:

let
  cfg = config.modules.plasma;
in
{
  options.modules.plasma = {
    enable = lib.mkEnableOption "Install and configure Plasma";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment = {
      systemPackages = with pkgs; [
        (catppuccin-kde.override { flavour = ["mocha"]; accents = ["blue"]; })
      ];
      plasma6.excludePackages = with pkgs.kdePackages; [
        plasma-browser-integration
        okular
        kate

        # I don't want to have Dolphin Plugins anyway, but just in case for future me:
        # the derivation for this may fail to build if you overlay dolphin.
        # Also even when this was installed it didn't seem to work anyway.
        dolphin-plugins
      ];
    };
  };
}
