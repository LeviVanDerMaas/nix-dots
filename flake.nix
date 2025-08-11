{
  description = ''
    Lorem Ipsum
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

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
  };

  outputs = { self, nixpkgs, ags, astal, ... }@flake-inputs: let
    arch = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${arch};
    lib = nixpkgs.lib;

    systemConfigsFor = systems: lib.genAttrs systems (system: lib.nixosSystem {
      specialArgs = { 
        inherit flake-inputs;
        rootRel = subPath: ./. + subPath;
      };
      modules = [ (import ./systems/${system}/configuration.nix) ];
    });
  in {
    nixosConfigurations = systemConfigsFor [ 
      "boo" 
      "lucy"
      "buffon"
    ];
    devShells.${arch}.ags = pkgs.mkShell {
      buildInputs = [
        (ags.packages.${arch}.default.override {
          extraPackages = with astal.packages.${arch}; [
            apps
            battery
            bluetooth
            hyprland
            mpris
            network
            notifd
            tray
            wireplumber
          ];
        })
      ];
    };
  };
}
