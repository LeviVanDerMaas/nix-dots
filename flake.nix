{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell/v4.7.7";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    levisNeovimConfig = {
      url = "github:LeviVanDerMaas/neovim-config";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = { self, nixpkgs, home-manager, ... }@flake-inputs:
    let
      flake-outputs = self.outputs;
      arch = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${arch};
      lib = nixpkgs.lib;
      fns = import ./fns { inherit pkgs lib; };

      # Extra args to pass to both NixOS modules and HM modules
      specialArgs = { inherit flake-inputs flake-outputs fns; };
    in
    {
      overlays = import ./overlays { inherit flake-inputs flake-outputs fns; };

      nixosConfigurations =
        let
          systemConfigFor = system: lib.nixosSystem {
            inherit specialArgs;
            modules = [ (import ./systems/${system}/configuration.nix) ];
          };
          systemConfigsFor = systems: lib.genAttrs systems systemConfigFor;
        in
        systemConfigsFor [
          "boo"
          "lucy"
          "buffon"
        ];

      # Note that these are generic imports as I like to use HM as a
      # NixOS module and use system specific tweaks. This is useful to access
      # when I wanna run just home-manager though, like for nixd.
      homeConfigurations =
        let
          HMConfigFor = user: home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = specialArgs;
            modules = [ (import ./homes/${user}) ];
          };
          HMConfigsFor = users: lib.genAttrs users HMConfigFor;
        in
        HMConfigsFor [
          "levi"
        ];
    };
}
