{ config, lib, fns, ... }:

{
  # General
  imports = [
    ./hardware-configuration.nix
    (fns.rootRel "nixos")
  ];

  # System name
  networking.hostName = "lucy";

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # No hibernation, too risky with Windows dual booting.
  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  # Custom config modules
  modules = {
    # System-wide
    hyprland.enable = true;
    plasma.enable = true;
    brightnessctl = {
      enable = true;
      brightnessKeys.minBrightness = 240;
    };

    # User-specific
    users.levi.enable = true;
  };





  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
