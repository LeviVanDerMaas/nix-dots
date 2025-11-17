{ pkgs, ... }:

let
  nix-sp = pkgs.writeShellScriptBin "nix-sp" (builtins.readFile ./nix-sp.sh);
in
{
  home.packages = [
    nix-sp
  ];
}
