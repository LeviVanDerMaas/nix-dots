{ pkgs, lib, config, ... }:

let
  cfg = config.modules.nixos.zsa;
in
{
  options.modules.nixos.zsa = {
    enable = lib.mkEnableOption "Set up ZSA udev rules and keymapp";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.zsa.enable = true; # udevs for flashing ZSA Moonlander keyboard
    environment.systemPackages = with pkgs; [
      keymapp
    ];
  };
}
