{ pkgs, ... }:

{
  home.packages = with pkgs.kdePackages; [
    dolphin
    ark

    # Dolphin needs support for svg icons, but does not package this by itself.
    qtsvg 

    # Optional deps:
    # kio-fuse # Needed to mount remote filesystems via FUSE
    # kio-extras # Extra remote filesystem protocols (sftp, fish and more)
  ];
}
