{ flake-inputs, pkgs, ... }:

{
  # General
  imports = [
      ./hardware-configuration.nix
      ../../modules/nixos
      flake-inputs.home-manager.nixosModules.home-manager
  ];
  networking.hostName = "lucy";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ../../overlays;





  # Users
  users.users.levi = {
    isNormalUser = true;
    description = "Levi";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit flake-inputs; };
    users = {
      levi = import ./home.nix;
    };
  };





  # Bootloader
  # MAKE SURE YOU HAVE READ THE HARDWARE CONFIG BEFORE CHANGING THE BOOTLOADER TO SOMETHING
  # OTHER THAN SYSTEMD-BOOT OR CHANGING THE MOUNT POINTS!
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

  # Disk
  zramSwap.enable = true;

  # No hibernation, too risky with Windows dual booting.
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Screen backlight control
  programs.light = {
    enable = true;
    brightnessKeys = {
      enable = true;
      step = 5;
    };
  }; 

  # Networking
  networking.networkmanager.enable = true;

  # Printing
  services.printing.enable = true; # Enables printing

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Locale
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };





  modules.nixos = {
    hyprland.enable = true;
    plasma.enable = true;
  };





  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
