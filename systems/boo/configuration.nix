{ pkgs, lib, fns, ... }:

{
  # General
  imports = [
    ./hardware-configuration.nix
    (fns.rootRel "nixos")
  ];

  # System Name
  networking.hostName = "boo";

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # Custom config modules
  modules = {
    # System-wide
    monitors.config = {
      DP-1 = {
        primary = true;
        position = { x = 0; y = 0; };
        resolution = { width = 1920; height = 1080; };
      };
      DP-3 = {
        position = { x = -1920; y = 0; };
        resolution = { width = 1920; height = 1080; };
      };
    };
    openrgb = {
      enable = true;
      serverStartDelay = 3;
      initRunArgs = ''-d "NZXT RGB & Fan Controller" -c 5D0167'';
      initRunDelay = 10;
      initRunTries = 20;
    };
    ddcutil.enable = true;
    piper.enable = true;
    zsa.enable = true;
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
  # this value at the release version of the first install of this system.boo
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
