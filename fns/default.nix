{ lib, ... }@args:

let
  composeCallables = import ./composeCallables.nix args;
in
composeCallables "fns" { extraArgs = args; } {
  # DO NOT include anything from the fns/pkgs dir here, instead it is better
  # to make those available via an overlay on a desired nixpkgs instance.
  helpers = ./helpers.nix;
  filesystem = ./filesystem.nix;
} // { inherit composeCallables; }
