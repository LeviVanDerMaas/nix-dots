# DO NOT include this file in fns/default.nix, as that makes fns dependent on a nixpkgs instance.
# Instead, import this seperately when you need it.

{
  fns ? import ./.. { inherit (pkgs) lib; },
  pkgs ? import <nixpkgs> {},
}:
let
  fnsArgs = { inherit fns pkgs; };
in
fns.composeCallables "fns" { extraArgs = fnsArgs // { inherit (pkgs) lib; }; } {
  packages = ./packages.nix;
  fetchers = ./fetchers.nix;
  files = ./files.nix;
} // { core = fns; }
