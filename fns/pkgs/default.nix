# DO NOT include this file in fns/default.nix, as that makes fns dependent on a nixpkgs instance.
# Instead, import this seperately when you need it.

{ lib, fns, pkgs }@args:

fns.composeCallables "fns" { extraArgs = args; } {
  packages = ./packages.nix;
  fetchers = ./fetchers.nix;
}
