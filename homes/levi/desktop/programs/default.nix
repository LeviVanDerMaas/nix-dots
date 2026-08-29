{ pkgs, ... }:

{
  imports = [
    ./dolphin.nix
    ./firefox.nix
    ./gpu-screen-recorder.nix
    ./kitty.nix
    ./texlive.nix
    ./vscode.nix
    ./zathura.nix
  ];

  # Non-module packages
  home.packages = with pkgs; [
    discord
    obsidian
    signal-desktop
    vlc
    pavucontrol # More advanced audio control
    networkmanagerapplet # has nm-connection-editor, a good GUI network editor
  ];
}
