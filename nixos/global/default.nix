{ pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bash.nix
    ./editor.nix
    ./fonts.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./printing.nix
    ./ssh.nix
    ./x.nix
    ./zram.nix
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];
}
