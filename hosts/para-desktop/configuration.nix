{ inputs, pkgs, ... }:

{
  networking.hostName = "para-desktop";

  imports = [
      ./hardware-configuration.nix
      ../../modules/nixos
      inputs.home-manager.nixosModules.home-manager
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Disk
  zramSwap.enable = true;

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

  # RGB
  modules.nixos.openrgb = {
    enable = true;
    serverStartDelay = 3;
    initRunArgs = ''-d "NZXT RGB & Fan Controller" -c 5D0167'';
    initRunDelay = 10;
    initRunTries = 10;
    initRunTryInterval = 5;
  };

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
    plasma.enable = true;
    steam.enable = true;
  };

  services = {
    printing.enable = true; # Enables printing
    openssh.enable = true; # SSH daemon
  };

  hardware.keyboard.zsa.enable = true; # udevs for flashing ZSA Moonlander keyboard

  # Hyprland
  programs.hyprland.enable = true;
  # Set desktop portal, needed for Hyprland.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  programs = {
    nano.enable = false;
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    bash = { 
      # Add a function to manage the brightness of the screen
      interactiveShellInit = ''
        br() {
          if [ $# -eq 1 ]; then
            ddcutil -d 1 setvcp x10 $1; ddcutil -d 2 setvcp x10 $1
          elif [ $# -eq 2 ]; then
            ddcutil -d $1 setvcp x10 $2;
          else
            echo "Use either <screen> <brightness> or <brightness>"
          fi
        }
      '';
    };

  };

  environment.systemPackages = with pkgs; [
    ddcutil
    keymapp
  ];





  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
