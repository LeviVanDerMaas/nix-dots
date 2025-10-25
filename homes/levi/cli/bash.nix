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

      ls = "ls --color=tty";
      l = "ls -Ah";
      ll = "ls -Ahl";

      zzz = "systemctl suspend";
    };
  };
}
