{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    leviNeovimConfig = {
      # No need to follow nixpkgs with the hmModule's `useHMPkgs` option
      url = "github:LeviVanDerMaas/neovim-config";
    };

    noctalia = {
      # Don't follow nixpkgs to take advantage of cachix
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
      fns = import ./fns { inherit lib; }; # Custom functions.
      overlays = import ./overlays { inherit fns; };
      specialArgs = { inherit inputs outputs fns; flake = self; };
    in
    {
      inherit overlays fns;

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
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
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
