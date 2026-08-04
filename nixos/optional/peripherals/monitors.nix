{ lib, config, ... }:

let
  monitors = config.modules.monitors;

  inherit (lib) mkOption types;
  nullableOption = s: mkOption (s // { type = types.nullOr s.type; default = s.default or null; });
  coordinateType = types.submodule {
    options = x: y: { 
      ${x} = mkOption { type = types.int; }; 
      ${y} = mkOption { type = types.int; };
    };
  };
in
{
  options.modules.monitors = mkOption {
    description = ''
      Shared monitor configuration settings. This module does not set anything directly but is instead
      intended to be consumed by other modules to set values based on this module.
    '';
    type = types.listOf (types.submodule {
      options = {
        port = mkOption {
          type = types.str;
          example = "DP-1";
        };
        primary = nullableOption {
          type = types.bool;
        };
        position = nullableOption {
          type = coordinateType "x" "y";
          example = { x = 1920; y = 1080; };
        };
        resolution = nullableOption {
          type = coordinateType "width" "height";
          example = { width = 1920; height = 1080; };
        };
        scale = nullableOption {
          type = types.number;
        };
        refreshRate = nullableOption {
          type = types.int;
        };
        modeline = nullableOption {
          type = types.str;
          description = "Xorg-style modeline, as described for the xorg.conf format";
        };
      };
    });
  };

  config = {
    modules.monitors = [];

    assertions = [
      {
        assertion = monitors != [] -> (lib.count (m: m.primary == true) monitors) <= 1;
        message = "At most 1 monitor may be set as primary.";
      }
    ];
  };
}
