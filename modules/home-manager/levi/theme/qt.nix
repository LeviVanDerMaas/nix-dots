{ pkgs, overlays, ... }:


{
  # nixpkgs.overlays = [ overlays.qt6ct-kde ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    kdePackages.qt6ct
    (catppuccin-kvantum.override {
      accent = "blue";
      variant = "macchiato";
    })
  ];

  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
    General.theme = "catppuccin-macchiato-blue";
  };
}
