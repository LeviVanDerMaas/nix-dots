{ lib, ... }:
{
  imports = [
    ./docker
    ./openrgb
    ./sddm
  ];

  # Toggelable modules that should be on by default
  docker.enable = lib.mkDefault true;
}
