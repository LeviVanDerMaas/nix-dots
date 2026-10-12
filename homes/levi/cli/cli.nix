{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zip # Create zip archives
    unzip # Unpack zip archives
    ffmpeg # Multimedia processing library
  ];
}
