{ lib, ... }:

rec {
  /**
    Take a subpath and resolve it relative to the flake's root directory.
  */
  rootRel = lib.path.append ./..;

  /**
    Take a subpath, resolve it relative to the flake's root directory,
    and import it.
  */
  rootRelImp = p: import (rootRel p);

  /**
    Given a function and a list of arguments, call the function with these arguments.
  */
  apply = f: args: lib.foldl' (f': arg: f' arg) f args;
}
