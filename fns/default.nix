{ pkgs, lib }:

rec {
  /**
    Like `lib.filesystem.listRecursive`, but only paths satisfying a predicate are
    included; if a directory is filtered out no files below it are included.
    The predicate must be a function that takes a path to the directory, the
    filename, and the filetype of the file being evaluated, and returns a boolean.

    WARNING: SYMLINKS TO DIRECTORIES DO NOT RECURSE, because Nix currently has no way to
    determine what kind of filetype a symlink resolves prior to using it in a builtin
    function that expects either a file or a dir and will abort if it gets the wrong one.
   */
  filterFilesRecursive =
    pred: dir:
    let
      internalRecurse =
        dir':
        let
          dirEntries = builtins.readDir dir';
          dirEntryToFilteredList =
            name: type:
            if !(pred dir' name type) then
              [ ]
            else if type == "directory" then
              internalRecurse (dir' + "/${name}")
            else
              [ (dir' + "/${name}") ];
        in
        builtins.concatLists (lib.mapAttrsToList dirEntryToFilteredList dirEntries);
    in
    internalRecurse dir;

  /**
    Given a path or list of paths, recursively discover Nix files under them
    and return a list of paths to them. Does not filter duplicates.
    IGNORES: files and directories starting with `_`, symlinks and other
    non-regular filetypes, and files not ending in `.nix`.
  */
  discoverNixFiles =
    let
      discoverNixFiles = filterFilesRecursive nixFilesPred;
      nixFilesPred =
        dir: name: type:
        !(lib.hasPrefix "_" name) &&
        (type == "regular" && lib.hasSuffix ".nix" name || type == "directory");
    in
    paths: builtins.concatMap (p: discoverNixFiles p) (lib.toList paths);

  /**
    Takes a string or path and makes it relative to the flake root.
  */
  rootRel = subPath: ../. + subPath;

  /**
    Given a function and a list of arguments, call the function with these arguments.
  */
  apply = f: args: lib.foldl' (f': arg: f' arg) f args;

  /**
    Take a package (derivation) and a version and warn if the package's version does not
    match the supplied version, then return the package.
  */
  checkPkgVersion = p: v: checkPkgVersion' p v p;

  /**
    Like `checkPkgVersion`, but takes an extra argument
    which will be the return value (much like builtins.warn).
  */
  checkPkgVersion' = p: v:
    let
      pv = lib.getVersion p;
      pvDiff = lib.compareVersions pv v != 0;
      msg = "Package ${lib.getName p} is now on version ${pv}; but checked for version ${v}!";
    in
    lib.warnIf pvDiff msg;

  /**
    Fetches a raw file at a given path in a github repo using fetchurl. Path
    should be relative to the repo root.
    Name will be the basenameOf the url if not given.
  */
  fetchRawFileFromGitHub = { owner, repo, rev, path, hash, name ? null }: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${lib.escapeURL path}";
    inherit hash name;
  };

  /**
    Given `package`, replace its specified executables with wrappers, using makeWrapper.
    By default this creates a "shim" package that links to all top-level directories and files
    except for `/bin`, where it instead links to all executables individually and then replaces
    the specified  executables with their wrappers. It is also possible to instead replace it
    in the original package directly, but that will rebuild the whole package.
  */
  wrapPkgExes = {
    package,
    wrappers, # [ { exe = <executableName>; makeWrapperArgs = [ <arg> <arg> ... ]; } ... ]
    wrappedPkgName ? package.name + "-wrapped", # name of the new package
    symlinkShim ? true # If false will build the full package!
  }:
    let
      makeWrapperSpec = w: {
        exe = lib.escapeShellArg w.exe;
        makeWrapperArgs = lib.escapeShellArgs w.makeWrapperArgs; 
        originalExe = "${package}/bin/${w.exe}";
        wrapperExe = "$out/bin/${w.exe}";
      };
      wrapperSpecs = lib.map makeWrapperSpec wrappers;
    in
    if symlinkShim then
      pkgs.runCommand wrappedPkgName { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir $out
        ln -s ${package}/* $out
        rm $out/bin
        mkdir $out/bin
        ln -s ${package}/bin/* $out/bin
        ${
          let
            emplaceWrapperSpec = ws: ''
              rm ${ws.wrapperExe}
              makeWrapper ${ws.originalExe} ${ws.wrapperExe} ${ws.makeWrapperArgs}
            '';
          in
          lib.concatMapStrings emplaceWrapperSpec wrapperSpecs
        }
      ''
    else
      package.overrideAttrs (prev: {
        name = wrappedPkgName;
        nativeBuildInputs = prev.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
        postFixup = prev.postFixup or "" +
          lib.concatMapStringsSep
          "\n"
          (ws: "wrapProgram ${ws.wrapperExe} ${ws.makeWrapperArgs}")
          wrapperSpecs;
      });

  /**
    Wrap one executable from a package, by default its main one, using makeWrapper.
    Convenience function around `wrapPkgExes`, to which it passes all arguments.
  */
  wrapPkgExe =
    {
      package,
      makeWrapperArgs, # Arguments to pass to the wrapper, in order
      exe ? package.meta.mainProgram, # name of the executable to be wrapped
      ...
    }@args:
    let
      args' = lib.removeAttrs args [ "makeWrapperArgs" "exe" ];
    in
    wrapPkgExes (args' // {
      wrappers = [ { inherit exe makeWrapperArgs; } ];
    });
}
