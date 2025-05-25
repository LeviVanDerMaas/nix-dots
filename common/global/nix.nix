{ rootRel, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    keep-derivations = true;
    keep-outputs = true;
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import (rootRel /overlays);
}
