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
      Configures the system for gaming, including installing games/launchers
      and other gaming-related programs such as gamescope by default.
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
