{ pkgs, ... }:

{
  imports = [
    ./qt.nix
    ./gtk.nix
    ./cursors.nix
  ];
}
