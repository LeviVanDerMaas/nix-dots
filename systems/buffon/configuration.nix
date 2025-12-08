{ pkgs, rootRel, lib, ... }:

let
  monitors = {
    main = "DP-2";
    left =  "HDMI-A-1";
  };
in
{
  # General
  imports = [
    ./hardware-configuration.nix
    (rootRel /nixos)
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
    ddcutil = {
      enable = true;
      numMonitors = 2;
    };
    sddm.setupCommands = with monitors; let
      xrandr = lib.getExe pkgs.xorg.xrandr;
    in ''
      ${xrandr} --output ${main} --primary
      ${xrandr} --output ${left} --left-of ${main}
    '';
    hyprland.enable = true;
    gaming.enable = true;

    # User-specific
    users.levi.enable = true;
    users.levi.extraHMConfig = {
      modules = {
        hyprland = {
          enable = true;
          monitors = with monitors; [
            {
              # If anything looks weird or blurry in certain apps its probs cuz of fractional scaling done here.
              name = "${main}"; resolution = "3840x2160"; position = "0x0"; scale = "1.5";
              bindWorkspaces = [ 1 2 3 4 5 ];
            }
            {
              name = "${left}"; resolution = "2560x1080"; position = "-2560x900"; scale = "1";
              bindWorkspaces = [ 6 7 8 9 10 ];
            }
          ];
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
