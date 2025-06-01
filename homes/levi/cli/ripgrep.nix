{ config, ... }:

{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden" 
      "--glob=!.nix-profile/*"
      "--glob=!.git/*"
      "--glob=!/nix/store/*"
    ];
  };
}
