{ pkgs, ... }:

{
  imports = [
    ./dolphin.nix
    ./kitty.nix
    ./firefox.nix
  ];

  # Non-module packages
  home.packages = with pkgs; [
    discord
    fastfetch
    obsidian
    vlc
  ];
}
