{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "i2c-dev" ];
  boot.extraModulePackages = [ ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BB0E-C81A";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/971f4a22-3956-48c5-8247-f0001178607f";
      fsType = "ext4";
    };
  fileSystems."/hdd" =
    { device = "/dev/disk/by-uuid/e3ece5ad-019a-45fe-9054-0bf42b2ad502";
      fsType = "ext4";
    };
  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
