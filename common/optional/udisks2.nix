{ pkgs, lib, config, ... }:

let
  cfg = config.common.udisks2;
in
{
  options.common.udisks2 = {
    enable = lib.mkEnableOption ''
      Enables the udisks2 module, a DBUS service that allows applications
      to query and manipulate storage devices. Mainly useful when there is
      no DE that provides an interface for managing this. For example,
      automounting can be accomplished through enabling this and then
      installing udiskie, which is an automounting daemon.
    '';
  };

  config = lib.mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
      # settings = {};
    };
  };
}
