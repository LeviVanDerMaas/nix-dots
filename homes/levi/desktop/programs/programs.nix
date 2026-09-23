{ pkgs, ... }:

{
  # Non-module packages
  home.packages = with pkgs; [
    discord
    obsidian
    signal-desktop

    # Media-stuff
    kdePackages.gwenview # Already has basic image editing
    vlc
    losslesscut # Basic video (and audio) editing without any re-encoding
    ffmpeg

    pavucontrol # More advanced audio control
    networkmanagerapplet # has nm-connection-editor, a good GUI network editor
  ];
}
