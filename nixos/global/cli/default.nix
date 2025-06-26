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
      # Set this here because nix already defines some stuff here by default.
      # I am overriding them with my prerred defaults.
      shellAliases = {
        ls = "ls --color=tty";
        l = "ls -Ah";
        ll = "ls -Ahl";
      };
    };
  };
}
