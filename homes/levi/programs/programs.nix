{ pkgs, ... }:

{
  # Non-module packages
  home.packages = with pkgs; [
    discord
    obsidian
    signal-desktop

    # Media-stuff
    qimgv # image viewer (uses mpv to view videos too)
    vlc # Video viewer
    mpv # Another video viewer, trying out alongside vlc for now
    losslesscut # Basic video (and audio) editing without any re-encoding
    handbrake # media conversion tool

    pavucontrol # More advanced audio control
    networkmanagerapplet # has nm-connection-editor, a good GUI network editor
  ];
}
