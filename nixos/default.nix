{ fns, ... }:

{
  imports = fns.discoverOtherNixFilesAt ./default.nix;
}
