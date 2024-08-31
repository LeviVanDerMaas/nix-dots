{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      dots-switch = "sudo nixos-rebuild switch --flake ~/.dots";
      dots-test = "sudo nixos-rebuild test --flake ~/.dots";
      diff = "${pkgs.difftastic}/bin/difft";
      zzz = "systemctl suspend";
    };
    initExtra = "${builtins.readFile ./interactiverc}";
  };
}
