{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      dots-switch = "sudo nixos-rebuild switch --flake ~/.dots";
      dots-boot = "sudo nixos-rebuild boot --flake ~/.dots";
      dots-test = "sudo nixos-rebuild test --flake ~/.dots";
      dots-dryb = "sudo nixos-rebuild dry-build --flake ~/.dots";
      dots-drya = "sudo nixos-rebuild dry-activate --flake ~/.dots";
      diff = "${pkgs.difftastic}/bin/difft";
      zzz = "systemctl suspend";
    };
  };
}
