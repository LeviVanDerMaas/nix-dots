{ pkgs, ... }:

{
  # There is a home-manager module too but it's very inflexible.
  home.packages = with pkgs; [
    texlive.combined.scheme-medium
  ];
}
