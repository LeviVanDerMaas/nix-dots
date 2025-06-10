{ pkgs, ... }:

{
  imports = [
    ./editor.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ]
  };
}
