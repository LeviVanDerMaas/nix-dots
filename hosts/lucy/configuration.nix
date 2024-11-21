flake-overlays:

{ inputs, pkgs, ... }:

{
  networking.hostName = "lucy";

  imports = [
      ./hardware-configuration.nix
      ../../modules/nixos
      inputs.home-manager.nixosModules.home-manager
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = flake-overlays;


  # Don't forget to set a password with ‘passwd’.
  users.users.levi = {
    isNormalUser = true;
    description = "Levi";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
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

  # No hibernation
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };




  environment.shellAliases = {
    vivado-flake = "nix run gitlab:doronbehar/nix-xilinx#vivado";
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
