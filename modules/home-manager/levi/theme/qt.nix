{ pkgs, overlays, ... }:


{
  qt = {
    enable = true;
    # platformTheme.name = "kde";
    # style.name = "breeze";
    # style.package = pkgs.kdePackages.breeze;
  };

  home.packages = with pkgs; [
    # The HM qt module does not actually seem to ship wayland support by default.
    libsForQt5.qtwayland
    kdePackages.qtwayland

    # libsForQt5.breeze-qt5
    kdePackages.breeze
    kdePackages.plasma-integration
    kdePackages.systemsettings
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "kde";
    QT_STYLE_OVRRIDE = "breeze";
  };
}
