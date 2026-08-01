{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland.monitors = lib.mkOption {
    description = ''
      Set up monior configuration. Furthermore, the first monitor will have
      workspaces 1 to 10 bound to it, the second monitor 11 to 20, and so on.
      First monitor will also be the cursor default.
    '';
    default = [];
    type = lib.types.listOf (lib.types.submodule {
      options = {
        output = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The `output` parameter passed to `hl.monitor`.
          '';
        };
        mode = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The `mode` parameter passed to`hl.monitor`.
          '';
        };
        position = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The `position` parameter passed to`hl.monitor`.
          '';
        };
        scale = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The `scale` parameter passed to`hl.monitor`.
          '';
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {
    # Set this early so that other config can depend on the (externally set) monitor config.
    wayland.windowManager.hyprland.extraConfig = lib.mkOrder 1 (
      let
        nixMonToLua = m: /* lua */ ''
          hl.monitor {
            output   = "${m.output}",
            mode     = "${m.mode}",
            position = "${m.position}",
            scale    = "${m.scale}"
          }
        '';
        hotpluggedMon = { output = ""; mode = "preferred"; position = "auto"; scale = "1"; };
        monConfigs = builtins.concatStringsSep ""
          (map nixMonToLua (cfg.monitors ++ [ hotpluggedMon ]));
        monNames = map (m: m.output) cfg.monitors;
      in
      /* lua */ ''
        ${monConfigs}
        MONITORS = { ${lib.optionalString (cfg.monitors != []) ''"${builtins.concatStringsSep ''", "'' monNames}" ''}}

        hl.config { cursor = { default_monitor = MONITORS[1] } }

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
