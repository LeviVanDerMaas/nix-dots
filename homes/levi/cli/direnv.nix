{ pkgs, rootRel, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  home.packages = [
    (pkgs.writeShellScriptBin "nix-direnv" ''
      usage() {
        cat <<'EOF'
      Quickly initialize a nix-direnv setup for a nix shell or flake.
      By default creates a nix shell with a simple template and opens it in your editor,
      then creates an .envrc that uses it, if neither exists yet.
        
      Flags:
      -f, --flake           Create a direnv using a nix flake.
      -e, --use_existing    Uses the existing nix shell or flake, if one exists. No effect if -o.
      -o, --overwrite       Overwrite nix shell or flake, if one exists.
      -h, --help            Display this help message, do not do anything else.
      EOF
      }
      parsed_args=$(getopt --name nixify --options 'feoh' --longoptions 'flake,use_existing,overwrite,help' -- "$@")
      eval "set -- $parsed_args"
      
      while true; do
        case "$1" in
          -f | --flake)
            flake=1
            shift;;
          -e | --use_existing)
            use_existing=1
            shift;;
          -o | --overwrite)
            overwrite=1
            shift;;
          -h | --help)
            usage
            exit 0;;
          --)
            shift
            if [[ $# -gt 0 ]]; then
              echo "ERROR - nixify does not accept non-flag arguments! Type \`nixify -h\` for help." >&2
              exit 1
            fi
            break;;
          *)
            echo "ERROR - Invalid flag: $1. Type \`nixify -h\` for usage help." >&2
            exit 1;;
        esac
      done

      if [[ -v flake ]]; then
        if [[ -e "flake.nix" ]]; then
          already_exists="flake.nix"
        fi
      elif [[ -e shell.nix ]]; then
        already_exists="shell.nix"
      elif [[ -e default.nix ]]; then
        already_exists="default.nix"
      fi
      
      if [[ -v already_exists ]]; then
         if [[ ! (-v use_existing || -v overwrite) ]]; then
          echo "ABORTING: $already_exists already exists! Use '-e' to use it instead, '-o' to overwrite." >&2
          exit 1
        fi
        file="$already_exists"
      elif [[ -v flake ]]; then
        file="flake.nix";
      else
        file="shell.nix";
      fi

      if [[ ! -v already_exists || -v overwrite ]]; then
        if [[ -v flake ]]; then
          file_content='{
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
      }'
        else
          file_content='let
        nixpkgs = <nixpkgs>;
      in
      { pkgs ? import nixpkgs {} }:

      pkgs.mkShell {
        packages = with pkgs; [

        ];
      }'
        fi
        cat > "$file" <<< $file_content
      fi

      # Here is where we actually edit the flake/shell.
      ''${EDITOR:-vim} $file

      if [[ ! -e ./.envrc ]]; then
        if [[ -v flake ]]; then
          echo "use flake" > .envrc
        else
          echo "use nix" > .envrc
        fi
        direnv allow
      else
        echo 'WARNING: .envrc already exists, not modifying. You may need to add `use nix` or `use flake` to it.' >&2
      fi
    '')
  ];
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
