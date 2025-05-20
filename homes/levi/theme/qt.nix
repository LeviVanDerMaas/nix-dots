{ pkgs, ... }:

{
  qt = {
    enable = true;
  };


  home.packages = with pkgs; [
    # The HM qt module does not actually seem to ship wayland support by default.
    libsForQt5.qtwayland
    kdePackages.qtwayland
  ];

  modules.kde.breeze.qt = {
    enable = true;
    force = true;
  };
}
