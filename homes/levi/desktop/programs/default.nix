{ pkgs, ... }:

{
  imports = [
    ./dolphin.nix
    ./firefox.nix
    ./kitty.nix
    ./texlive.nix
    ./zathura.nix
  ];

  # Non-module packages
  home.packages = with pkgs; [
    discord
    obsidian
    signal-desktop
    vlc
  ];
}
