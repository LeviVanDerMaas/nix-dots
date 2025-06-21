{ pkgs, rootRel, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  programs.bash.initExtra = ''
    shell-env() {
      if [[ ! -e ./.envrc ]]; then
        echo "use nix" > .envrc
        direnv allow
      fi
      if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
        cat > shell.nix <<'EOF'
    with import <nixpkgs> {};
    mkShell {
      packages = [
        
      ];
    }
    EOF
        ''${EDITOR:-nvim} shell.nix
      fi
    }

    flake-env() {
      if [[ ! -e ./.envrc ]]; then
        echo "use flake" > .envrc
        direnv allow
      fi
      if [[ ! -e flake.nix ]]; then
        if [[ $# -gt 0 ]]; then
          nix flake new -t $@ .
        else 
          nix flake new -t ${(rootRel /.)}#basic-shell .
        fi
        ''${EDITOR:-nvim} flake.nix
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
