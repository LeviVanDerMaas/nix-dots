{ pkgs, ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = let
      rebuild = "sudo nixos-rebuild --flake .";
    in {
      dots-switch = "${rebuild} switch";
      dots-boot = "${rebuild} boot";
      dots-test = "${rebuild} test";
      dots-dryb = "${rebuild} dry-build";
      dots-drya = "${rebuild} dry-activate";

      nixpkgs-repl = "nix repl --expr 'import <nixpkgs> {}'";

      ls = "ls --color=auto --hyperlink=auto";
      l = "ls -Ah";
      ll = "ls -Ahl";

      zzz = "systemctl suspend";
    };

    # There is both initExtra and bashrcExtra. They do the same except
    # initExtra places its stuff after an interactive shell guard while
    # bashrcExtra runs uncoditionally. Eventhough .bashrc is usually
    # not automtically sourced by non-interave shells, there are some weird
    # edge cases where it does like remote shells.
    initExtra = ''
      nixpkgs=${pkgs.path}

      whichr() { realpath $(which $@); }
      whichd() { dirname $(which $@); }
      whichrd() { dirname $(realpath $(which $@)); }
    '';
  };
}
