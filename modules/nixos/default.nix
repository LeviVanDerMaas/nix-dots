{ lib, ... }:
{
  imports = [
    ./docker
    ./openrgb
  ];

  # Toggelable modules that should be on by default
  docker.enable = lib.mkDefault true;
}
