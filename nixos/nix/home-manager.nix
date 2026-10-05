{ inputs, extraModuleArgs, ... }:

# Note that this configures only the HM NixOS module and has no effect for standalone.
{

  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager = {
    useGlobalPkgs = true;

    # Do not inherit specialArgs directly from the `specialArgs` module argument,
    # as that can mess things up live override HM's modulesPath with NixOS's.
    extraSpecialArgs = extraModuleArgs;
  };
}
