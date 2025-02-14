{ pkgs, overlays, ... }:


{
  # nixpkgs.overlays = with overlays; [ qt5ct-kde qt6ct-kde ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  home.packages = with pkgs; [
    # The HM qt module does not actually seem to ship wayland support by default.
    libsForQt5.qtwayland
    kdePackages.qtwayland

    # libsForQt5.breeze-qt5
    kdePackages.breeze
  ];
}
