{ specialArgs, ... }:

# Note that this configures only the HM NixOS module and has no effect for standalone.
{
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = specialArgs;
  };
}
