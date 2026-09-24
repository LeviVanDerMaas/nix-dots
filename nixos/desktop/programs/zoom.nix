{ lib, config, ... }:

let
  cfg = config.modules.zoom;
in
{
  # I hate zoom but I gotta use it for some stuff.
  # And I guess it was nice enough of them to provide a linux implementation.
  options.modules.zoom = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zoom-us.enable = true;
  };
}
