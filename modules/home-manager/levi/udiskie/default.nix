{ config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.udiskie;
in
{
  options.modules.home-manager.levi.udiskie = {
    enable = lib.mkEnableOption ''
      Front-end for udisks2. Also allows auto-mounting. services.udisks2.enable must
      be true on the system config side, otherwise this service cannot run effectively.
    '';
  };

  config = lib.mkIf cfg.enable {
    services.udiskie = {
      # If I see correctly, this module will autostart a systemd-service
      # for udiskie AFTER a graphical session has started.
      enable = true;
      automount = true;
    };
  };
}
