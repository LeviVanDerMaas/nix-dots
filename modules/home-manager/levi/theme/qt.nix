{ pkgs, ... }:

{
  qt = {
    enable = true;
  };


  # The HM qt module is not designed with installing Breeze6 in mind,
  # so we should handle installation of Breeze 6 (and 5) ourselves.
  home.packages = with pkgs; [
    # The HM qt module does not actually seem to ship wayland support by default.
    libsForQt5.qtwayland
    kdePackages.qtwayland

  ];

  modules.home-manager.levi.kde.breeze.qt = {
    enable = true;
    force = true;
  };
}
