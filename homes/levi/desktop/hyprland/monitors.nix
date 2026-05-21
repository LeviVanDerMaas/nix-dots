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
        wsToMonBind = mon: ws:
          /* lua */ "hl.workspace_rule { workspace = ${ws}, monitor = \"${mon}\" }";
        IthWsRangeToMonBinds = i: mon:
          let
            r = 10 * i + 1;
            r' = r + 9;
            wsRange = map toString (lib.range r r');
          in
          map (wsToMonBind mon) wsRange;
        wsBinds =
          let
            mons = map (m: toString m.output) cfg.monitors;
            bindsPerMon = lib.imap0 IthWsRangeToMonBinds mons;
            bindsAllMons = builtins.concatLists bindsPerMon;
          in
          builtins.concatStringsSep "\n" bindsAllMons;
      in
      /* lua */ ''
        ${monConfigs}
        ${defaultMon}
        ${wsBinds}
      '';
  };
}
