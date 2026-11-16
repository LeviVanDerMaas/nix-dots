{
  lib ? import <nixpkgs/lib>
}@args:

let
  composeCallables = import ./composeCallables.nix args;
in
composeCallables "fns" { extraArgs = args; } {
  helpers = ./helpers.nix;
  filesystem = ./filesystem.nix;
} // { inherit composeCallables; }
