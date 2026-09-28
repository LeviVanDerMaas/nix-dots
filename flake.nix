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
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
      fns = callComponent ./fns; # Custom library
      overlays = callComponent ./overlays;

      # Extra args to pass to both NixOS modules and HM modules, as well as to
      # config components called with `callComponent`
      specialArgs = { inherit inputs outputs callComponent fns; };

      # Import a non-module config component and pass it the same arguments as a module.
      callComponent = file: import file (specialArgs // { inherit pkgs lib callComponent; });

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
            inherit pkgs;
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
