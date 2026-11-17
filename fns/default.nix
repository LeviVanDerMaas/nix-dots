{
  lib ? import <nixpkgs/lib>
}:

let
  # Default function args are NOT bound by the @-construct
  fnsArgs = { inherit lib; };
  composeCallables = import ./composeCallables.nix fnsArgs;
in
composeCallables "fns" { extraArgs = fnsArgs; } {
  helpers = ./helpers.nix;
  filesystem = ./filesystem.nix;
} // { inherit composeCallables; }
