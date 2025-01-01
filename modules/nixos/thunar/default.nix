{ pkgs, lib, config, ... }:

let
  cfg = config.modules.nixos.thunar;
in
{
  options.modules.nixos.thunar = {
    enable = lib.mkEnableOption ''
      Thunar file manager. Although part of the xfce DE, it works pretty
      well outside of that environment.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.thunar.enable = true;
  }
}
