{ pkgs, lib, config, ... }:

let
  cfg = config.modules.zsa;
in
{
  options.modules.zsa = {
    enable = lib.mkEnableOption "Set up ZSA udev rules and keymapp";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.zsa.enable = true; # udevs for flashing ZSA Moonlander keyboard
    environment.systemPackages = with pkgs; [
      keymapp
    ];
  };
}
