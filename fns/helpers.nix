{ lib, callComponent, ... }:

{
  # Make callComponent also available under fns for convenience
  inherit callComponent;

  /**
    Takes a string or path and makes it relative to the flake root.
  */
  rootRel = subPath: ../. + subPath;

  /**
    Given a function and a list of arguments, call the function with these arguments.
  */
  apply = f: args: lib.foldl' (f': arg: f' arg) f args;
}
