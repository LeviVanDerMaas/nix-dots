{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland.monitors = lib.mkOption {
    description = ''
      Set up monior configuration: the reason we have this as its own submodule in our
      home-manager config is because monitor setup is quite system dependent, so this
      lets us configure different monitor setups for different systems while keeping the
      rest of our config uniform between systems.
    '';
    default = {};
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The name parameter of Hyprland's "monitor" keyword.
          '';
        };
        resolution = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The resolution parameter of Hyprland's "monitor" keyword.
          '';
        };
        position = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The position parameter of Hyprland's "monitor" keyword.
          '';
        };
        scale = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            The scale parameter of Hyprland's "monitor" keyword.
          '';
        };
        bindWorkspaces = lib.mkOption {
          type = lib.types.listOf (lib.types.either lib.types.int lib.types.str);
          default = [];
          description = ''
            Workspaces that are to be bound to this monitor. The
            first workspace will also be the default for the monitor.
          '';
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      monitor = 
        lib.optionals (cfg.monitors.useRecommendedFallbackRule)  [ ", preferred, auto, 1" ]
        ++ 
        builtins.map  (mr: "${mr.name}, ${mr.resolution}, ${mr.position}, ${mr.scale}") cfg.monitors.rules;
      
      # Binds (default) workspaces to monitors as indicated in cfg.bindWorkspaces
      workspace = builtins.concatMap
        (mr: lib.optionals (mr.bindWorkspaces != []) (
          [ "${builtins.toString (builtins.head mr.bindWorkspaces)}, default:true" ]
          ++
          builtins.map (w: "${builtins.toString w}, monitor:${mr.name}") mr.bindWorkspaces
        ))
        cfg.monitors.rules;
    };
  };
}
