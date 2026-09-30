{ lib, ... }@args:

let
  fnsArgs = args // { inherit fns; };
  callFns = file: import file fnsArgs;

  fns = {
    helpers = callFns ./helpers.nix;
    filesystem = callFns ./filesystem.nix;
    packages = callFns ./packages.nix;
    fetchers = callFns ./fetchers.nix;
  };
in
lib.mergeAttrsList (builtins.attrValues fns) // fns
