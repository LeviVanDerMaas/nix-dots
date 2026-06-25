{ pkgs, lib }:

rec {
  # Takes a string or path and makes it relative to the flake root.
  rootRel = subPath: ../. + subPath;

  # Given a function and a list of arguments, call the function with these arguments.
  apply = f: args: lib.foldl' (f': arg: f' arg) f args;

  # Fetches a raw file at a given path in a github repo using fetchurl. Path
  # should be relative to the repo root
  # Name will be the basenameOf the url if not given
  fetchRawFileFromGitHub = { owner, repo, rev, path, hash, name ? null }: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${lib.escapeURL path}";
    inherit hash name;
  };

  # Given a package, replace its executable (by default tries to determine the
  # primary executable) with a wrapper. By default this does not modify the
  # actual package, but rather works on a symlink-copied directory structure to
  # avoid triggering a rebuild of the actual package.
  wrapPkgExe = {
    package,
    wrapperArgs, # Arguements to pass to the wrapper, in order
    exePath ? null, # should be relative to the package's store path
    packageName ? package.name + "-wrapped", # name of the package
    symlinkShim ? true # If false will rebuild the full package!
  }:
    let
      exe = if exePath != null then "$out/${exePath}" else "$out/bin/${package.meta.mainProgram}";
      callWrapProgram = "wrapProgram ${exe} ${lib.escapeShellArgs wrapperArgs}";
    in
    if symlinkShim then
      pkgs.symlinkJoin {
        name = packageName;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        paths = [ package ];
        postBuild = callWrapProgram;
      }
    else
      package.overrideAttrs (prev: {
        name = packageName;
        nativeBuildInputs = prev.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
        postFixup = prev.postFixup or "" + ''
          ${callWrapProgram}
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
