{ pkgs, lib, config, ... }:

let
  cfg = config.common.gaming;
in
{
  imports = [
    ./steam.nix
  ];

  options.common.gaming = {
    enable = lib.mkEnableOption ''
      Configures the system for gaming, including installing games/launchers
      themselves. By default will also enable the steam config.
    '';
  };

  config = lib.mkIf cfg.enable {
    common.steam.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      prismlauncher
      r2modman
    ];
  };
}
