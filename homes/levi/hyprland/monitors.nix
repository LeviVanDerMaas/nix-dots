{ config, lib, osConfig ? {}, ... }:

let
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland.monitors = {
    config = lib.mkOption {
      description = ''
        Set up monior configuration. Furthermore, the first monitor will have
        workspaces 1 to 10 bound to it, the second monitor 11 to 20, and so on.

        If Home Manager is ran as a NixOS module, then any monitor configuration
        set at system level will also be used as (individually) overridable defaults
        for this option.
      '';
      default = {};
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          output = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = ''
              Defaults to the attribute name.
            '';
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          position = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          scale = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
        };
      }));
    };

    defaultMonitor = lib.mkOption {
      default = osConfig.modules.monitors.primary or null;
      type = lib.types.nullOr lib.types.str;
      description = "The name of the monitor to which the cursor should be set on startup";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set system level monitor configuration as individually overridable defaults
    modules.hyprland.monitors.config =
      let
        sysMons = osConfig.modules.monitors.config or {};
        sysMonToDefaultHyprMon = n: m:
          let
            nullableFieldMap = prop: to: if m.${prop} != null then to else null;
          in
          lib.mkDefault {
            output = m.port;
            ${nullableFieldMap "position" "position"} = "${toString m.position.x}x${toString m.position.y}";
            ${nullableFieldMap "scale" "scale"} = "${toString m.scale}";
            ${nullableFieldMap "resolution" "mode"} =
              "${toString m.resolution.width}x${toString m.resolution.height}" +
              "${lib.optionalString (m.refreshRate != null) "@${toString m.refreshRate}"}";
          };
      in
      lib.mapAttrs sysMonToDefaultHyprMon sysMons;

    # Lua monitor config: set early so that other config can depend on the (externally set) monitor config.
    wayland.windowManager.hyprland.extraConfig = lib.mkOrder 1 (
      let
        nixMonToLua = n: m: /* lua */ ''
          hl.monitor {
            output   = "${m.output}",
            mode     = "${m.mode}",
            position = "${m.position}",
            scale    = "${m.scale}"
          }
        '';
        hotpluggedMonDefault = { "" = { output = ""; mode = "preferred"; position = "auto"; scale = "1"; }; };
        monConfigs = (lib.concatMapAttrsStringSep "" nixMonToLua (hotpluggedMonDefault // cfg.monitors.config));
        monOutputNames = lib.mapAttrsToList (n: m: m.output) cfg.monitors.config;
        defaultMonitor = cfg.monitors.defaultMonitor;
        setDefaultMon = lib.optionalString (defaultMonitor != null)
          /* lua */ ''hl.config { cursor = { default_monitor = "${defaultMonitor}" } }'';
      in
      /* lua */ ''
        ${monConfigs}
        ${setDefaultMon}
        MONITORS = { ${lib.optionalString (cfg.monitors.config != {}) ''"${builtins.concatStringsSep ''", "'' monOutputNames}" ''}}

        -- For the i'th monitor, bind workspaces [1, 10] * i to it
        local function bindIthWsRangeToMon(i, mon)
          local wsRangeBase = 10 * i + 1
          for ws = wsRangeBase, wsRangeBase + 9 do
            hl.workspace_rule { workspace = tostring(ws), monitor = mon }
          end
        end
        for i, mon in ipairs(MONITORS) do
          bindIthWsRangeToMon(i - 1, mon)
        end

        -- Given `n` in the range [1, 10] and, optionally, `monitor`, convert `n` to an absolute
        -- id that is unique to that monitor.
        -- NOTE: This function makes sure that the returned ids align to the ordering in MONITORS,
        -- but otherwise relies soley on the id of the monitor to return a unique workspace id.
        function map1to10toUniqueIdForMon(n, mon)
          if tonumber(n) < 1 or tonumber(n) > 10 then error("workspace_relative10OnMonToId: n must be in range [1, 10]") end

          mon = hl.get_monitor(mon) or hl.get_active_monitor()
          if not mon then return nil end -- Failsafe
          local mon_name = mon.name

          -- If monitor not in list, its id can be used to find a free range as fallback.
          local configged_mon_count = #MONITORS
          local mon_prio = array_indexOf(MONITORS, mon_name) or (configged_mon_count + mon.id)
          if configged_mon_count > 0 then mon_prio = mon_prio - 1 end
          return mon_prio * 10 + n
        end
      ''
    );
  };
}
