{
  description = "Basic flake with Nix shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }: let
    arch = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${arch};
    lib = nixpkgs.lib;
  in {
    devShells.${arch}.default = pkgs.mkShell {
      packages = with pkgs; [ 
        
      ];
    };
  };
}
