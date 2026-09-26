{ pkgs, lib, fns, ... }:

{
  # General
  imports = [
    ./hardware-configuration.nix
    (fns.rootRel "nixos")
  ];

  # System Name
  networking.hostName = "buffon";

  # Nvidia RTX 2080
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  # Custom config modules
  modules = {
    # System-wide
    monitors.config = {
      DP-2 = {
        primary = true;
        position = { x = 0; y = 0; };
        resolution = { width = 3840; height = 2160; };
        scale = 1.5;
      };
      HDMI-A-1 = {
        position = { x = -2560; y = 900; };
        resolution = { width = 2560; height = 1080; };
      };
    };
    ddcutil.enable = true;
    hyprland.enable = true;
    gaming.enable = true;

    # User-specific
    users.levi.enable = true;
    users.levi.extraHMConfig = {
      modules = {
        hyprland = {
          enable = true;
          integrations.gaming.enable = true;
        };
      };
    };
  };





  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
