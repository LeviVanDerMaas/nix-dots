{ flake-inputs, rootRel, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit flake-inputs rootRel; };
  };
}
