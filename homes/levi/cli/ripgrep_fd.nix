{ lib, ... }:

let
  module = {
    programs.fd = {
      enable = true;
      extraOptions = [
        "--follow"
      ];
    };

    xdg.configFile."fd/ignore".source = globalIgnoreFile;
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--follow"
        "--smart-case"
        "--ignore-file=${globalIgnoreFile}"
        "--no-messages" # suppresses a bunch of error messages around symlinks and special OS file
      ];
    };

    home = {
      file.".ignore".source = homeIgnoreFile;
      shellAliases = {
        "root-fd" = "fd ${lib.concatMapStringsSep " " (p: "--exclude ${p}") rootIgnores}";
        "root-rg" = "rg ${lib.concatMapStringsSep " " (p: "--glob=!${p}") rootIgnores}";
      };
    };
  };

  # Filtering these out in the root dir, alongside the other ignore rules
  # below, makes searching the entire filesystem with rg very fast even with
  # --hidden --follow, and still includes virtually everything relevant. Cannot
  # globally ignore absolute paths, so including these in an alias will do. 
  rootIgnores = [
    "/proc/"
    "/sys/"
    "/tmp/"
    "/var/run/" # It's a symlink to /run
    "/run/booted-system" # The nixos config that the system booted with, not the active one
  ];

  globalIgnoreFile = builtins.toFile "ripgrep_fd_ignore_global" /* gitignore */ ''
    # nix dirs:
    # Filter out most duplicate symlinks and files not used in the current active system.
    /nix/store/
    /nix/var/log/
    /nix/var/nix/profiles
    /nix/var/nix/gcroots
    # **/.nix-profile/ Mostly unique except small overlap with XDG_*_HOME due to being on XDG_*_DIRS
    **/.local/state/nix/profiles/
    **/.local/state/home-manager/gcroots/
    **/.nix-defexpr/
    **/.cache/nix

    # git dir
    .git/
  '';

  homeIgnoreFile = builtins.toFile "ripgrep_fd_ignore_home" /* gitignore */ ''
    # In the home dir search hidden entries even without --hidden:
    # Usually when you're running a search in the home dir you wanna include these anyway.
    # This feature is documented in `man rg` at the `--hidden` flag, and works for fd too
    !/.*

    # Except for those ignored below:
    # XDG dirs
    /.cache/
    /.local/share/Trash/

    # undo dirs
    /.local/state/*/undo/

    # Game dirs
    /.steam/
    /.local/share/Steam/
    /.wine/
    /.local/share/PrismLauncher/
    /.config/r2modmanPlus-local/
  '';
in
module
