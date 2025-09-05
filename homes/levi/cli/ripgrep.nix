{ config, ... }:

{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden" 
      "--smart-case" # case-insensitive if all lower-case.
      "--glob=!.nix-profile/*"
      "--glob=!.git/*"
      "--glob=!/nix/store/*"
    ];
  };
}
