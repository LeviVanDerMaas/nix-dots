{ pkgs, overlays, ... }:


{

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    # style.package = pkgs.kdePackages.breeze;
  };

  home.packages = [
    pkgs.libsForQt5.breeze-qt5
    # pkgs.kdePackages.breeze
    # pkgs.libsForQt5.qt5ct
  ];
}
