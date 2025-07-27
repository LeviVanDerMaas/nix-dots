{ flake-inputs, rootRel, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
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
