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
    wayland.windowManager.hyprland.extraConfig =
      let
        # Monitor configurations
        monToLua = m: /* lua */ ''
          hl.monitor {
            output   = "${m.output}",
            mode     = "${m.mode}",
            position = "${m.position}",
            scale    = "${m.scale}"
          }
        '';
        hotpluggedMon = { output = ""; mode = "preferred"; position = "auto"; scale = "1"; };
        monConfigs = builtins.concatStringsSep ""
          (map monToLua (cfg.monitors ++ [ hotpluggedMon ]));


        # Set default monitor to first given monitor
        defaultMon =
          let
            firstMon = (builtins.head cfg.monitors).output;
          in
          lib.optionalString (cfg.monitors != [])
            /* lua */ "hl.config { cursor = { default_monitor = \"${firstMon}\" } }";


        # Bind groups of ten workspaces to each monitor in order
        monNames = map (m: m.output) cfg.monitors;
        wsRangesToMonBinds = lib.optionalString (cfg.monitors != []) (
          let
            luaMonNameArray = ''{ "${builtins.concatStringsSep ''", "'' monNames}" }'';
          in
          /* lua */ ''
            local function bindIthWsRangeToMon(i, mon)
              local wsRangeBase = 10 * i + 1
              for ws = wsRangeBase, wsRangeBase + 9 do
                hl.workspace_rule { workspace = tostring(ws), monitor = mon }
              end
            end
            for i, mon in ipairs(${luaMonNameArray}) do
              bindIthWsRangeToMon(i - 1, mon)
            end
          ''
        );
      in
      /* lua */ ''
        ${monConfigs}
        ${defaultMon}
        ${wsRangesToMonBinds}
      '';
  };
}
