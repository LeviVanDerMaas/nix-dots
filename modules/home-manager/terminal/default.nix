
# modules/home-manager/terminal/default.nix

{
  imports = [
    ./bash
    ./kitty.nix
    ./starship.nix
  ];
}
