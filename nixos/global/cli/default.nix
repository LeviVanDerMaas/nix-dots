{ pkgs, ... }:

{
  imports = [
    ./editor.nix
  ];

  config = {
    environment = { 
      systemPackages = with pkgs; [
        wl-clipboard
      ];
      # Set this here because nix already sets defautls here
      shellAliases = {
        ls = "ls --color=tty";
        l = "ls -Ah";
        ll = "ls -Ahl";
      };
    };
  };
}
