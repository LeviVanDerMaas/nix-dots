{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    levisNeovimConfig = {
      url = "github:LeviVanDerMaas/neovim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      outputs = self.outputs;
      lib = nixpkgs.lib;
      fns = import ./fns { inherit pkgs lib; }; # Custom lib
      overlays = import ./overlays { inherit inputs outputs; };

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      specialArgs = { inherit inputs outputs fns; flake = self; };
    in
    {
      inherit overlays;
      nixosConfigurations =
        let
          systemConfigFor = host: lib.nixosSystem {
            inherit specialArgs;
            modules = [ ./systems/${host}/configuration.nix ];
          };
          systemConfigsFor = hosts: lib.genAttrs hosts systemConfigFor;
        in
        systemConfigsFor [
          "boo"
          "lucy"
          "buffon"
        ];

      # Note that these are generic standalone configurations, while I prefer
      # to use HM as a NixOS module and then tweak per system. However, this is
      # useful to access when I want to run just home-manager, like for nixd.
      homeConfigurations =
        let
          HMConfigFor = user: home-manager.lib.homeManagerConfiguration {
            inherit pkgs; # Home-manager will make its config default and use its overlays
            extraSpecialArgs = specialArgs;
            modules = [ ./homes/${user} ];
          };
          HMConfigsFor = users: lib.genAttrs users HMConfigFor;
        in
        HMConfigsFor [
          "levi"
        ];
    };
}
