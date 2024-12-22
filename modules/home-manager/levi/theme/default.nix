{ pkgs, ... }:

{
  # gtk = {
  #   enable = true;
  #   theme = {
  #     name = "Breeze-Dark";
  #     package = pkgs.kdePackages.breeze-gtk;
  #   };
  #   iconTheme = {
  #     name = "Breeze-Dark";
  #     package = pkgs.kdePackages.breeze-icons;
  #   };
  #   cursorTheme = {
  #     name = "Breeze-Dark";
  #     # Breeze includes its cursor in the global theme
  #     package = pkgs.kdePackages.breeze-gtk;
  #   };
  #   gtk3 = {
  #     extraConfig.gtk-application-prefer-dark-theme = true;
  #   };
  # };
  #
  # # It doesn't seem possible to set Breeze Dark to be used directly
  # # through the qt module for nix, however you can make Breeze Dark
  # # the theme of gtk and then coax qt to follow the gtk style, which
  # # should work for most appplications
  # qt = {
  #     enable = true;
  #     platformTheme.name = "gtk";
  #     style = {
  #       name = "gtk2";
  #       package = pkgs.kdePackages.breeze;
  #     };
  # };
}
