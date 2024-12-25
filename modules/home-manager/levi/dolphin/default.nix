{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.dolphin

    # Dolphin can run without these packages, but it may or may not run into
    # issues or look very borked. The nixos wiki recommends installing these
    # alongside Dolphin as well.
    kdePackages.qtwayland
    kdePackages.qtsvg
    
    # These are needed if you want to mount remote filesystems.
    # kdePackages.kio-fuse #to mount remote filesystems via FUSE
    # kdePackages.kio-extras #extra protocols support (sftp, fish and more)
  ];
}
