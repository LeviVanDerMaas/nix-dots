{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zip # Create zip archives
    unzip # Unpack zip archives
    ffmpeg # Multimedia processing library
    file # Utitlity for determining filetype based on content
    dragon-drop # Drag-drop from the terminal (named 'dragon' upstream)
  ];
}
