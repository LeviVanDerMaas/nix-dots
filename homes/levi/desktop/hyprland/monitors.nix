{ config, lib, ... }:

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
      # The first rule will be a fallback rule, so that hotplugging unknown monitors should still work.
      monitor = [ ", preferred, auto, 1" ] ++
        builtins.map (mon: "${mon.name}, ${mon.resolution}, ${mon.position}, ${mon.scale}") cfg.monitors;
      
      # Binds workspaces to monitors as indicated in cfg.bindWorkspaces,
      # and set the first workspace for a monitor as the default workspace.
      workspace = builtins.concatMap (mon: let
        wss = mon.bindWorkspaces;
        defaultRule = lib.optionals (mon.bindWorkspaces != []) 
          [ "${builtins.toString (builtins.head wss)}, default:true" ];
        bindRules = builtins.map (ws: "${builtins.toString ws}, monitor:${mon.name}") wss;
      in defaultRule ++ bindRules) cfg.monitors;
    };
  };
}
