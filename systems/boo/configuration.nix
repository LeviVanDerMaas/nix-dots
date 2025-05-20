{ pkgs, ... }:

{
  # General
  imports = [
    ./hardware-configuration.nix
    ../../common
  ];

  # System Name
  networking.hostName = "boo";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Disk
  zramSwap.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Printing
  services.printing.enable = true; # Enables printing





  # Configuration derived from common config.
  common = {
    ddcutil = {
      enable = true;
      numMonitors = 2;
    };
    openrgb = {
      enable = true;
      serverStartDelay = 3;
      initRunArgs = ''-d "NZXT RGB & Fan Controller" -c 5D0167'';
      initRunDelay = 10;
      initRunTries = 20;
    };
    sddm.setupCommands = "${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --left-of DP-1";
    hyprland.enable = true;
    zsa.enable = true;
    gaming.enable = true;
  };





  # User specific config
  common.users.levi.enable = true;
  common.users.levi.extraHMConfig = {
    modules = {
      hyprland = {
        enable = true;
        monitors.rules = [
          { 
            name = "DP-1"; resolution = "1920x1080"; position = "0x0"; scale = "1";
            bindWorkspaces = [ 1 2 3 4 5 ];
          }
          { 
            name = "DP-3"; resolution = "1920x1080"; position = "-1920x0"; scale = "1";
            bindWorkspaces = [ 6 7 8 9 10 ];
          }
        ];

        integrations = {
          discord.autoStart = true;
          gaming.enable = true;
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
  system.stateVersion = "24.05"; # Did you read the comment?
}
