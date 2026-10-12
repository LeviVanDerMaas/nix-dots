{ pkgs, ... }:

{
  home.packages = with pkgs; [ playerctl ];

  # This daemon makes playerctl default to the most recently active media
  # instead of the first supported player found.
  services.playerctld.enable = true;
}
