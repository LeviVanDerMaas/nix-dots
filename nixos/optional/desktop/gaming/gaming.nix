{ pkgs, lib, config, ... }:

let
  cfg = config.modules.gaming;
in
{
  imports = [
    ./steam.nix
    ./gamescope.nix
  ];

  options.modules.gaming = {
    enable = lib.mkEnableOption ''
      Configures the system for gaming, and installs launchers, gamescope, and
      other gaming(-related) programs.
    '';
  };

  config = lib.mkIf cfg.enable {
    modules.gaming = {
      steam.enable = lib.mkDefault true;
      gamescope.enable = lib.mkDefault true;
    };

    environment.systemPackages = with pkgs; [
      prismlauncher
      r2modman
    ];
  };
}
