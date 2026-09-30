{ lib, ... }:

{
  /**
    Take a subpath and resolve it relative to the flake's root directory.
  */
  rootRel = lib.path.append ./..;

  /**
    Given a function and a list of arguments, call the function with these arguments.
  */
  apply = f: args: lib.foldl' (f': arg: f' arg) f args;
}
