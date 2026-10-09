{ lib, ... }:

let
  module = {
    programs.fd = {
      enable = true;
      extraOptions = [
        "--hidden"
        "--follow"
      ];
    };

    xdg.configFile."fd/ignore".source = globalIgnoreFile;
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--follow"
        "--smart-case"
        "--ignore-file=${globalIgnoreFile}"
      ];
    };

    home.shellAliases = {
      "root-fd" = "fd ${lib.concatMapStringsSep " " (p: "--exclude ${p}") rootIgnores}";
      "root-rg" = "fd ${lib.concatMapStringsSep " " (p: "--glob !${p}") rootIgnores}";
    };
  };

  # Cannot globally ignore absolute paths, so including these in an alias will have to do
  rootIgnores = [
    "proc/"
    "sys/"
    "tmp/"
    "var/run/" # It's a symlink to /run
    "run/booted-system" # The nixos config that the system bootwed with, not the active one
  ];
  globalIgnoreFile = builtins.toFile "ripgrep_fd_ignore" /* gitignore */ ''
    # nix dirs
    # Filter out most duplicate symlinks and files not used in the current active system.
    # Makes even `fd --follow` at root fast if /proc/, /sys/ are also ignored.
    /nix/store/
    /nix/var/log/
    /nix/var/nix/profiles
    /nix/var/nix/gcroots
    **/.nix-profile/
    **/.local/state/nix/profiles/
    **/.local/state/home-manager/gcroots/
    **/.nix-defexpr/
    **/.cache/nix

    # git dir
    .git/

    # undo dirs
    **/.local/state/nvim/undo/

    # xdg dirs
    .cache
    **/.local/share/Trash/

    # Game dirs
    **/.steam/
    **/.local/share/Steam/
    **/.wine
    **/.local/share/PrismLauncher/
    **/.config/r2modmanPlus-local/
  '';
in
module
