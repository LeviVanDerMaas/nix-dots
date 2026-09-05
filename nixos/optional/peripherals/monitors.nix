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
      type = types.attrsOf (types.submodule ({ name, ... }:
        let
          thisMon = cfg.config.${name};
        in
        {
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
              description = ''
                Assume logical scaling, which is what Wayland compositor favor: that is, the monitor
                resolution is scaled before *output* is mapped to it. As such, the "physical" geometry
                of the monitor effectively becomes `(width/scale)x(height/scale)` and you must take
                that into account for things like positioning the monitor in coordinate space.

                For output scaling, which is favored by X11, look at `descaledResolution`.
              '';
            };
            refreshRate = nullableOption {
              type = types.int;
            };
            modeline = nullableOption {
              type = types.str;
              description = "Xorg-style modeline, as described for the xorg.conf format.";
            };

            descaledResolution = nullableOption {
              type = coordinateType "width" "height";
              readOnly = true;
              description = ''
                If this monitor has its `scale` and `resolution` options set, this contains the
                resolution divided by the scale. This is useful in cases where output scaling is
                needed, e.g. you can use this resolution with `xrandr`'s `--scale-from` flag to get
                generally the same effect as applying logical scaling (which xrandr does not support)
                using the `scale` option set here.
              '';
              default =
                let
                  s = thisMon.scale;
                  r = thisMon.resolution;
                in
                if s != null && r != null then
                  # We need ints, builtin.floor makes them ints again.
                  { width = builtins.floor (r.width / s); height = builtins.floor (r.height / s); }
                else
                  null;
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
          filterMappableProps = m: lib.removeAttrs (lib.filterAttrs (p: v: v != null) m) [ "name" "scale" ];

          propMappers = {
            port = v: "--output ${v}";
            primary = v: lib.optionalString v "--primary";
            position = v: "--pos ${toString v.x}x${toString v.y}";
            resolution = v: "--mode ${toString v.width}x${toString v.height}";
            descaledResolution = v: "--scale-from ${toString v.width}x${toString v.height}";
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

    primary = lib.mkOption {
      type = types.nullOr types.str;
      readOnly = true;
      description = "Name of the monitor set as the primary monitor.";
    };
  };

  config =
    let
      monitorList = lib.attrValues cfg.config;
      singlePrimaryMonitor = lib.findSingle (m: m.primary == true) null false monitorList;
    in
    {
      assertions = [
        {
          assertion = singlePrimaryMonitor != false;
          message = "At most 1 monitor may be set as primary.";
        }
      ];
      modules.monitors.primary =
        if singlePrimaryMonitor != null then singlePrimaryMonitor.name else null;
    };
}
