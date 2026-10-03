{ fns, ... }:

{
  # Adds the utility functions in `fns/pkgs`. These are here via an overlay instead of directly on
  # the main `fns` set to keep `fns` independent of a nixpkgs instance. This also avoids needing to
  # create and evaluate a second instance of nixpkgs (expensive) just to use these functions when building NixOS or HM.
  fns = final: prev: { fns = fns.rootRelImp "fns/pkgs" { inherit fns; pkgs = final; lib = final.lib; }; };

  # Temporary overlays, e.g. for applying fixes not yet in nixpkgs.
  temporary = final: prev: {
  };
}
