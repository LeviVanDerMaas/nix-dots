{ config, ... }:

{
  # General
  imports = [
      ./hardware-configuration.nix
      ../../common
  ];

  # System name
  networking.hostName = "lucy";

  # Bootloader
  # MAKE SURE YOU HAVE READ THE HARDWARE CONFIG BEFORE CHANGING THE BOOTLOADER TO SOMETHING
  # OTHER THAN SYSTEMD-BOOT OR CHANGING THE MOUNT POINTS!
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

  # No hibernation, too risky with Windows dual booting.
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Disk
  zramSwap.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Printing
  services.printing.enable = true; # Enables printing





  # Configuration derived from common config.
  common = {
    hyprland.enable = true;
    plasma.enable = true;
    backlight.enable = true;
  };




  # User specific config.
  common.users.levi.enable = true;
  common.users.levi.extraHMConfig = {
    hyprland.enable = true;
    kde.symlink-kdeglobals = !config.common.plasma.enable;
  };





  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
