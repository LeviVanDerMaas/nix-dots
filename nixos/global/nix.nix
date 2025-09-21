{ flake-inputs, rootRel, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Read note below to understand what keep-{derivations,outputs} actually do
    keep-derivations = true;
    keep-outputs = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import (rootRel /overlays);
  };
  environment.variables = { NIXPKGS_ALLOW_UNFREE = 1; };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit flake-inputs rootRel; };
  };
}

# Note on garbage collection of derivations and build-time-only outputs:
# After doing some digging through the manual and EDolstra's thesis:
# - Live store paths are all store paths reachable through the references of all
#   GC-roots.
# - In the case of derivations, these references are *exactly* the union of:
#   the store paths to all of the derivation's inputs (inputSrcs; e.g. C
#   compiler) AND the store paths to all of the derivations that must be built
#   before this derivation can (inputDrvs; e.g. derivation that builds the C
#   compiler).
# - keep-derivations will keep a derivation live if its output is live. Since a
#   derivation references all its input derivations, a live output can
#   will recursively make all derivations needed to build it live.
# - keep-outputs will keep the outputs of all live derivations live as well
#   (whereas ordinarily an output is live only if registered as root or
#   referenced by another live path).
# - This means that combining keep-derivations and keep-outputs will
#   transitively prevent garbage collection of all build-time-only inputs of a
#   live output (like those in your runtime environment).
