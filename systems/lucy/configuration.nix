{ config, lib, rootRel, ... }:

{
  # General
  imports = [
    ./hardware-configuration.nix
    (rootRel /nixos)
  ];

  # System name
  networking.hostName = "lucy";

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # No hibernation, too risky with Windows dual booting.
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Custom config modules
  modules = {
    # System-wide
    hyprland.enable = true;
    plasma.enable = true;
    backlight.enable = true;

    # User-specific
    users.levi.enable = true;
    users.levi.extraHMConfig = let
      usingPlasma = config.modules.plasma.enable;
    in {
      modules = {
        kde.enable = !usingPlasma;
        qt.enable = !usingPlasma;
        hyprland.enable = true;
        hyprland.extraEnv = lib.optionals usingPlasma [
          "QT_QPA_PLATFORMTHEME,kde" # Makes QT theming also managed by kde on Hyprland
        ];
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
