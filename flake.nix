{
  description = ''
    Top-level flake for my NixOS and home-manager configs. This is a config
    designed to be usuable by multiple systems: modules are designed to be
    always imported, and their configs are made to be toggleable (using
    lib.mkIf) for more fine-grained control per system when desired. As such,
    this flake is not desigend to be consumed by other flakes.
  '';

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

  outputs = { self, nixpkgs, ... }@flake-inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;

    systemConfigsFor = hosts: lib.genAttrs hosts (host: lib.nixosSystem {
      specialArgs = { inherit flake-inputs; };
      modules = [ (import ./hosts/${host}/configuration.nix) ];
    });
  in {
    nixosConfigurations = systemConfigsFor [ 
      "boo" 
      "lucy"
    ];
  };
}
