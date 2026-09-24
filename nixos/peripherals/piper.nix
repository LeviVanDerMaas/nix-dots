{ pkgs, config, lib, ... }:

let
  cfg = config.modules.piper;
in
{
  options.modules.piper = {
    enable = lib.mkEnableOption "
      Install `Piper`, a GUI over the `ratbagd` daemon, a daemon primarly for
      configuring gaming mice. This will also enable the ratbagd daemon.
    ";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ piper ];
    services.ratbagd.enable = true;
  };
}
