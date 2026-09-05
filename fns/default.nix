{ pkgs, lib }:

rec {
  # Takes a string or path and makes it relative to the flake root.
  rootRel = subPath: ../. + subPath;

  # Given a function and a list of arguments, call the function with these arguments.
  apply = f: args: lib.foldl' (f': arg: f' arg) f args;

  # Take a package (derivation) and a version and warn if the package's version does not
  # match the supplied version, then return the next argument (much like builtins.warn).
  # Useful for things like warning you that a package you're overriding has been updated.
  checkPkgVersion = p: v:
    let
      pv = lib.getVersion p;
      pvDiff = lib.compareVersions pv v != 0;
      msg = "Package ${lib.getName p} is now on version ${pv}; but checked for version ${v}!";
    in
    lib.warnIf pvDiff msg;

  # Fetches a raw file at a given path in a github repo using fetchurl. Path
  # should be relative to the repo root
  # Name will be the basenameOf the url if not given
  fetchRawFileFromGitHub = { owner, repo, rev, path, hash, name ? null }: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${lib.escapeURL path}";
    inherit hash name;
  };

  # Given `package`, replace its executable  with a wrapper. By default this creates a "shim"
  # package that links to all top-level directories (and files) except for `/bin`, where it instead
  # links to all executables individually and then replaces the main executable with the wrapper. It
  # is also possible to instead replace it in the original package directly, but that will rebuild
  # the whole package.
  wrapPkgExe = {
    package,
    wrapperArgs, # Arguements to pass to the wrapper, in order
    exeName ? package.meta.mainProgram, # name of the executable to be wrapped
    packageName ? package.name + "-wrapped", # name of the package
    symlinkShim ? true # If false will rebuild the full package!
  }:
    let
      originalExe = "${package}/bin/${exeName}";
      wrapperExe = "$out/bin/${exeName}";
    in
    if symlinkShim then
      pkgs.runCommand packageName { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir $out
        ln -s ${package}/* $out
        rm $out/bin
        mkdir $out/bin
        ln -s ${package}/bin/* $out/bin
        rm ${wrapperExe}
        makeWrapper ${originalExe} ${wrapperExe} ${lib.escapeShellArgs wrapperArgs}
      ''
    else
      package.overrideAttrs (prev: {
        name = packageName;
        nativeBuildInputs = prev.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
        postFixup = prev.postFixup or "" + ''
          wrapProgram ${wrapperExe} ${lib.escapeShellArgs wrapperArgs}
        '';
      });

  # Given a package, produce from it an executable that wraps another executable
  # from said package: by default this is the executable returned by lib.getExe.
  # Note this wrapper is under a different store path than the orginal executable.
  wrapPkgExeExternally = {
    package,
    wrapperArgs, # Arguments to pass to the wrapper, in order
    wrapperName ? package.meta.mainProgram, # The name of the wrapper
    exePath ? null, # should be relative to the package's store path
    packageName ? package.name + "-wrapped", # name of the package
  }:
    let
      exe = if exePath != null then "${package}/${exePath}" else lib.getExe package;
    in
    pkgs.runCommand packageName { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${exe} $out/bin/${wrapperName} ${lib.escapeShellArgs wrapperArgs}
    '';
}
