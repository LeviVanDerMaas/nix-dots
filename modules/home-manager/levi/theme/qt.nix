{ pkgs, overlays, ... }:


{
  # nixpkgs.overlays = [ overlays.qt6ct-kde ];

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.package = pkgs.kdePackages.breeze;
    style.name = "breeze";
  };

  home.packages = [
    pkgs.kdePackages.breeze
  ];
}
