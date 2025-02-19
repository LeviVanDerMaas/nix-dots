{
  description = "Top-level flake for NixOs and home-manager configs";
  # To initially use this flake, make sure configuration.nix has
  # nix.settings.experimental-features = [ "nix-command" "flakes" ]

  # inputs declares all dependencies of the flake.
  inputs = {
    # Makes the flake fetch nixpkgs from the unstable branch,
    # i.e. makes all nixpkgs available at "cutting-edge" versions.
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    # Fetches the home manager flake.
    home-manager.url = "github:nix-community/home-manager/master";
    # Makes sure nixpkgs of home-manager follows our own, thus preventing installing seperate
    # pkg versions for home-manager.
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Experimental release containing controls my rgb fans, expected to be merged into v 0.10
    openrgb.url = "github:CalcProgrammer1/OpenRGB?rev=b5638eee126234ebfe8eb7fe240d7b732f5d5dc3";
    openrgb.flake = false;

    # Catppuccin theme for bat
    batThemeCatppuccin.url = "github:catppuccin/bat/main";
    batThemeCatppuccin.flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs: 

  let
    overlays = import ./overlays { inherit inputs; };
  in
  {
    inherit overlays;

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
