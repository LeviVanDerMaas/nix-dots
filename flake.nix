{
  description = "Top-level flake for my NixOS and home-manager configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    openrgb = { # Experimental release with support for my fans, will be merged in v0.10
      url = "github:CalcProgrammer1/OpenRGB?rev=b5638eee126234ebfe8eb7fe240d7b732f5d5dc3";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: rec {
    overlays = import ./overlays { inherit inputs; };

    nixosConfigurations = {
      "boo" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs overlays; };
        modules = [ (import ./hosts/boo/configuration.nix) ];
      };
      "lucy" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs overlays; };
        modules = [ (import ./hosts/lucy/configuration.nix) ];
      };
    };
  };
}
