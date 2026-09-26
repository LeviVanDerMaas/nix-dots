{ pkgs, lib, fns, ... }:

rec {
  /**
    Wraps `builtins.dirOf` to abort if the path does not exist.
  */
  strictDirOf =
    file:
    if builtins.pathExists file then
      dirOf file
    else
      abort "path '${file}' does not exist";

  /**
    Given a directory, return a (non-recursive) list of all entries in that directory.
  */
  listFilesIn = dir:
    map (name: dir + "/${name}") (builtins.attrNames (builtins.readDir dir));

  /**
    Like `fns.listFilesIn`, but takes a file and lists its directory (non-recursively).
  */
  listFilesAt = file: listFilesIn (strictDirOf file);

  /**
    Like `fns.listFilesAt`, but excludes the passed file.
    Useful to generate non-recursive import lists, e.g. for a directory of NixOS modules.
  */
  listOtherFilesAt = file: lib.remove file (listFilesAt file);

  /**
    Like `fns.listFilesIn`, but only paths satisfying a predicate are included.
    The predicate must be a function that takes filename and the filetype of
    the file being evaluated, and returns a boolean.
  */
  filterFilesIn =
    pred: dir:
    lib.mapAttrsToList (name: type: dir + "/${name}") (lib.filterAttrs pred (builtins.readDir dir));

  /**
    Like `fns.filterFilesIn`, but takes a file and lists its directory (non-recursively).
  */
  filterFilesAt = pred: file: filterFilesIn pred (strictDirOf file);

  /**
    Like `fns.filterFilesAt`, but excludes the passed file.
    Useful to generate non-recursive import lists, e.g. for a directory of NixOS modules.
  */
  filterOtherFilesAt = pred: file: lib.remove file (filterOtherFilesAt pred file);

  /*
    Like `lib.filesystem.listFilesRecursive`, but also accepts either a non-directory
    path or a list of paths of any kind. Does not filter duplicates.

    WARNING: SYMLINKS TO DIRECTORIES DO NOT RECURSE, neither does `lib.filesystemlistFilesRecursive`.
  */
  listFilesRecursive' =
    let
      listFileOrDir = p:
        if builtins.readFileType p == "directory" then
          lib.filesystem.listFilesRecursive p
        else
         [ p ];
    in
    paths: builtins.concatMap listFileOrDir (lib.toList paths);

  /**
    Like `fns.listFilesRecursive'`, but only paths satisfying a predicate are
    included; if a directory is filtered out no files below it are included.
    The predicate must be a function that takes a path to the directory, the
    filename, and the filetype of the file being evaluated, and returns a boolean.

    WARNING: SYMLINKS TO DIRECTORIES DO NOT RECURSE, because Nix currently has no way to
    determine what kind of filetype a symlink resolves prior to using it in a builtin
    function that expects either a file or a dir and will abort if it gets the wrong one.
   */
  filterFilesRecursive =
    pred: paths:
    let
      internalDirRecurse = dir: builtins.concatLists (
        lib.mapAttrsToList (dirEntryToFilteredList dir) (builtins.readDir dir)
      );
      dirEntryToFilteredList =
        dir: name: type:
        if !(pred dir name type) then
          [ ]
        else if type == "directory" then
          internalDirRecurse (dir + "/${name}")
        else
          [ (dir + "/${name}") ];

      pathToFilteredList =
        p: dirEntryToFilteredList (dirOf p) (baseNameOf p) (builtins.readFileType p);
    in
    builtins.concatMap pathToFilteredList (lib.toList paths);

  /**
    Given a directory or list of directories, recursively discover Nix files under them
    and return a list of paths to each file in. Does not filter duplicates.
    IGNORES: files and directories starting with `_`, symlinks and other
    non-regular filetypes, and files not ending in `.nix`.
  */
  discoverNixFiles =
    let
      nixFilesPred =
        dir: name: type:
        !(lib.hasPrefix "_" name) &&
        (type == "regular" && lib.hasSuffix ".nix" name || type == "directory");
    in
    paths: filterFilesRecursive nixFilesPred paths;

  /**
    Like `fns.discoverNixFiles`, but accepts only a single file and recursively
    discovers all Nix files within the parent directory of the file EXCEPT for
    the passed file.
    Primarly useful when you want one Nix file in a subtree to manage all other
    Nix files in that subtree (e.g default.nix); when you pass the calling file,
    this generates a list of all *other* Nix files in its subtree, but excludes
    the calling file to prevent it from recursively importing itself.
  */
  discoverOtherNixFilesAt = file: discoverNixFiles (listOtherFilesAt file);
}
