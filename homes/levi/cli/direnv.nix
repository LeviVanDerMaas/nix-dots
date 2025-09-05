{ pkgs, rootRel, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  programs.bash.initExtra = ''
    shellify() {
      if [[ -e ./shell.nix ]] || [[ -e ./default.nix ]]; then
        echo 'ABORTING: ./shell.nix or ./default.nix already exists!'
        return 1
      fi
      ''${EDITOR:-nvim} - +'f shell.nix' +'set ft=nix' <<EOF
    let
      nixpkgs = <nixpkgs>;
    in
    { pkgs ? import nixpkgs {} }:

    pkgs.mkShell {
      packages = with pkgs; [

      ];
    }
    EOF
      if [[ ! -e ./shell.nix ]]; then
        echo 'ABORTING: no ./shell.nix written!'
        return 1
      fi
      if [[ ! -e ./.envrc ]]; then
        echo "use nix" > .envrc
        direnv allow
      else
        echo './.envrc already exists, not modifying. You may need to add `use nix` to it.'
      fi
    }

    flakify() {
      if [[ -e flake.nix ]]; then
        echo 'ABORTING: ./flake.nix already exists!'
        return 1
      fi
      ''${EDITOR:-nvim} - +'f flake.nix' +'set ft=nix' <<EOF
    {
      description = "Basic flake with Nix shell";
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

      outputs = { nixpkgs, ... }: let
        arch = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.''${arch};
        lib = nixpkgs.lib;
      in {
        devShells.''${arch}.default = pkgs.mkShell {
          packages = with pkgs; [ 
            
          ];
        };
      };
    }
    EOF
      if [[ ! -e ./flake.nix ]]; then
        echo 'ABORTING: no ./flake.nix written!'
        return 1
      fi
      if [[ ! -e ./.envrc ]]; then
        echo "use nix" > .envrc
        direnv allow
      else
        echo './.envrc already exists, not modifying. You may need to add `use flake` to it.'
      fi
    }
  '';
}
# To satisfy my own curiosity:
# nix-direnv pulls off its symlinking build dependencies by adding an indirect root (symlink)
# to a build of your shell/flake. An indirect symlink is a (poorly documented,
# though pretty important) feature where you have a symlink that points out
# of the store to another symlink that points to your built shell in the store.
# When the garbage connecter checks liveness of store paths, for indirect roots it
# checks if the symlink (outside the store) that the root points to still exists:
# - If it does it then the store path that THAT symlink points to is considered live
# - Otherwise it removes the indirect symlink from gcroots

# These symlink SHOULD be stored under /nix/var/nix/gcroots/auto, from what I
# can tell the source code of the garbage collector won't even properly
# handle indirect symlinks when they are not under auto.
