{ pkgs, lib, config, ... }:

let
  cfg = config.modules.monitors;

  inherit (lib) mkOption types;
  nullableOption = s: mkOption (s // { type = types.nullOr s.type; default = s.default or null; });
  coordinateType = x: y: types.submodule {
    options = { 
      ${x} = mkOption { type = types.int; }; 
      ${y} = mkOption { type = types.int; };
    };
  };
in
{
  options.modules.monitors = {
    config = mkOption {
      description = ''
        Shared monitor configuration settings. This does not set anything directly but is instead
        intended to be consumed by other modules to set values based on this module.
      '';
      default = {};
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            readOnly = true;
            description = "The attribute name given to this monitor.";
            default = name;
          };
          port = mkOption {
            type = types.str;
            example = "DP-1";
            description = "Port via which the monitor is connected. Defaults to the attribute name.";
            default = name;
          };
          primary = nullableOption {
            type = types.bool;
            default = false;
          };
          position = nullableOption {
            type = coordinateType "x" "y";
            default = { x = 1920; y = 1080; };
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
            description = "Xorg-style modeline, as described for the xorg.conf format.";
          };
        };
      }));
    };

    xrandrSetupCommand = lib.mkOption {
      type = types.str;
      readOnly = true;
      description = "An xrandr shell command that when ran configures monitors as specified by this module.";
      default =
        let
          monConfs = config.modules.monitors.config;
          filterMappableProps = m: lib.removeAttrs (lib.filterAttrs (p: v: v != null) m) [ "name" ];

          propMappers = {
            port = v: "--output ${v}";
            primary = v: lib.optionalString v "--primary";
            position = v: "--pos ${toString v.x}x${toString v.y}";
            resolution = v: "--mode ${toString v.width}x${toString v.height}";
            scale = v: "--scale ${toString v}";
            refreshRate = v: "--rate ${toString v}";
            modeline = v: "--newmode customMode ${v} --mode customMode"; # Dunno if this works
          };
          monConfToXrandrFlags = m: lib.concatMapAttrsStringSep
            " " (p: v: propMappers.${p} v) (filterMappableProps m);

          joinedXrandrFlags = lib.concatMapAttrsStringSep
            " \\\n  " (p: v: monConfToXrandrFlags v) monConfs;
        in
        lib.optionalString (monConfs != {}) "${lib.getExe pkgs.xrandr} ${joinedXrandrFlags}";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.config != {} ->
          (lib.count (m: m.primary == true) (lib.attrValues cfg.config)) <= 1;
        message = "At most 1 monitor may be set as primary.";
      }
    ];
  };
}
