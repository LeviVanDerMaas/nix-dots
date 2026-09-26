{ lib, callComponent, ... }:

let
  fns = {
    helpers = callComponent ./helpers.nix;
    filesystem = callComponent ./filesystem.nix;
    packages = callComponent ./packages.nix;
    fetchers = callComponent ./fetchers.nix;
  };
in
lib.mergeAttrsList (builtins.attrValues fns) // fns
