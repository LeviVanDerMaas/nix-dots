{ inputs, pkgs, overlays, ... }:

{
  networking.hostName = "boo";

  imports = [
      ./hardware-configuration.nix
      ../../modules/nixos
      inputs.home-manager.nixosModules.home-manager
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [overlays.hello-test overlays.cowsay-test overlays.xilinx];

  # Don't forget to set a password with ‘passwd’.
  users.users.levi = {
    isNormalUser = true;
    description = "Levi";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs overlays; };
    users = {
      levi = import ./home.nix;
    };
  };





  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Disk
  zramSwap.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true; # Enables printing

  # Networking
  networking.networkmanager.enable = true;

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




  environment.shellAliases = {
    vivado-flake = "nix run gitlab:doronbehar/nix-xilinx#vivado";
  };

  modules.nixos = {
    ddcutil = {
      enable = true;
      numMonitors = 2;
    };
    sddm.setupCommands = "${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --left-of DP-1";
    hyprland.enable = true;
    openrgb = {
      enable = true;
      serverStartDelay = 3;
      initRunArgs = ''-d "NZXT RGB & Fan Controller" -c 5D0167'';
      initRunDelay = 10;
      initRunTries = 10;
      initRunTryInterval = 5;
    };
    thunar.enable = true;
    steam.enable = true;
    zsa.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hello
    cowsay
  ];





  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
