# This module is directly based on home-manager's modules/misc/xdg/default.nix

{ pkgs, config, lib, inputs, ... }:

let
  cfg = config.modules.xdg;

  inherit
    (
      (import "${inputs.home-manager}/modules/lib/file-type.nix" {
        inherit (config.home) homeDirectory;
        inherit lib pkgs;
      })
    )
    fileType
    ;

  mkSecondaryXdgRootOption = name: lib.mkOption {
    type = lib.types.str;
    default = "${cfg.secondaryXdgRoot}/${name}";
    description = ''
      Absolute path to secondary XDG ${name} directory.
    '';
  };

  mkSecondaryXdgFileOption = optName: basePath: lib.mkOption {
    type = fileType optName "{var} `${optName}`" basePath;
    default = {};
    description = ''
      Attribute set of files to link into secondary xdg file hierarchy
      corresponding to this option.
    '';
  };
in
{
  options.modules.xdg = {
    secondaryXdgRoot = lib.mkOption {
      type = lib.types.str;
      default = config.home.homeDirectory + "/.secondaryxdg";
      description = ''
        Absolute path to a directory holding a "secondary" hierarchy of XDG directories.
        These directories will be prepended to the appropriate `XDG_*_DIRS` path.
        Useful when you want your primary XDG files to manageable by an application,
        but still want to manage lower-priority defaults with Home Manager (in cases
        where an application merges the results across XDG directories).
      '';
    };

    secondaryConfigRoot = mkSecondaryXdgRootOption "config";
    secondaryConfigFile = mkSecondaryXdgFileOption "modules.xdg.secondaryConfigFile" cfg.secondaryConfigRoot;

    secondaryDataRoot = mkSecondaryXdgRootOption "share";
    secondaryDataFile = mkSecondaryXdgFileOption "modules.xdg.secondaryDataFile" cfg.secondaryDataRoot;
  };

  config = {
    home.file = lib.mkMerge [
      (lib.mapAttrs' (name: file: lib.nameValuePair "${cfg.secondaryConfigRoot}/${name}" file) cfg.secondaryConfigFile)
      (lib.mapAttrs' (name: file: lib.nameValuePair "${cfg.secondaryDataRoot}/${name}" file) cfg.secondaryDataFile)
    ];
    xdg.systemDirs.config = [ cfg.secondaryConfigRoot ];
    xdg.systemDirs.data = [ cfg.secondaryDataRoot ];
  };
}
