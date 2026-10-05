{ pkgs, lib, ... }:

{
  /**
    Creates a derivation ofa file that is a symlink to the absolute of `path`.
    Notably, this symlink can point to files outside of the nix store and thus lets
    you create symlinks to live paths.
    This is stolen directly from home-manager's `lib.mkOutOfStoreSymlink`
  */
  mkOutOfStoreSymlink =
    path: 
    let
      pathStr = toString path; # Direct path interpolation would turn it into a store path.
      name = "symlink_to_" + (baseNameOf pathStr);
    in
    pkgs.runCommandLocal name {} "ln -s ${lib.escapeShellArg pathStr} $out";
}
