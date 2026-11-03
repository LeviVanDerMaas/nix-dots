{ inputs, pkgs,  extraModuleArgs, ... }:

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

  # Temporarily allow this for losslesscut in HM. However, upstream has already bumped electron
  nixpkgs.config.permittedInsecurePackages = pkgs.fns.checkPkgVersion' pkgs.losslesscut "3.70.1" [
    "electron-42.11.18"
  ];
}
