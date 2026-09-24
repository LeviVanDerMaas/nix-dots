{ flake-inputs, specialArgs, ... }:

# Note that this configures only the HM NixOS module and has no effect for standalone.
{

  imports = [
    flake-inputs.home-manager.nixosModules.home-manager
  ];
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = specialArgs;
  };
}
