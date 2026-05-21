{ pkgs, lib, fns, ... }:

let
  monitors = {
    main = "DP-1";
    left = "DP-3";
  };
in
{
  # General
  imports = [
    ./hardware-configuration.nix
    (fns.rootRel /nixos)
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
    sddm.setupCommands = with monitors; let
      xrandr = lib.getExe pkgs.xrandr;
    in ''
      ${xrandr} --output ${main} --primary
      ${xrandr} --output ${left} --left-of ${main}
    '';
    hyprland.enable = true;
    piper.enable = true;
    zsa.enable = true;
    gaming.enable = true;

    # User-specific
    users.levi.enable = true;
    users.levi.extraHMConfig = {
      modules = {
        hyprland = {
          enable = true;
          monitors = with monitors; [
            { output = "${main}"; mode = "1920x1080"; position = "0x0"; scale = "1"; }
            { output = "${left}"; mode = "1920x1080"; position = "-1920x0"; scale = "1"; }
          ];
          # TODO: Reenable this once ported to Lua
          # integrations.gaming.enable = true;
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
