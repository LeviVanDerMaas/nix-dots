{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  imports = [
    ./integrations
    ./binds.nix
    ./exec.nix
    ./hyprpaper.nix
    ./windowrules.nix
  ];

  options.modules.home-manager.levi.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
    monitors = lib.mkOption {
      description = ''
        Set up monior configuration: the reason we have this as its own submodule in our
        home-manager config is because monitor setup is quite system dependent, so this
        lets us configure different monitor setups for different systems while keeping the
        rest of our config uniform across systems.
      '';
      default = {};
      type = lib.types.submodule {
        options = {
          useRecommendedFallbackRule = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Adds the rule `monitor = , preferred, auto, 1` as the first monitor rule.
              This rule is recommended by the Hyprland wiki as a fallback rule to set up
              monitor hot-plugging. This rule typically results in each new monitor being
              placed to the right of already existing monitors.
            '';
          };
          rules = lib.mkOption {
            description = ''
              Set up monitor rules, as well as create workspace rules that bind workspaces
              to a specified monitor.
            '';
            default = [];
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
                  type = lib.types.listOf lib.types.str;
                  default = [];
                  description = ''
                    Workspaces that are to be bound to this monitor. The
                    first workspace will also be the default for the monitor.
                  '';
                };
              };
            });
          };
        };
      };
    };
    integrateDunst = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable and autostart Dunst messaging daemon.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      blueberry # simple bluetooth control
      grimblast
      hyprpolkitagent
      hyprpicker
      wl-clipboard # Hyprland needs this
      ulauncher
    ];

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        monitor = 
          lib.optionals 
          (cfg.monitors.useRecommendedFallbackRule)  [ ", preferred, auto, 1" ]
          ++ 
          builtins.map 
          (mr: "${mr.name}, ${mr.resolution}, ${mr.position}, ${mr.scale}") cfg.monitors.rules;
        
        # Binds (default) workspaces to monitors as indicated in cfg.bindWorkspaces
        workspace = builtins.concatMap
          (mr: lib.optionals (mr.bindWorkspaces != []) (
            [ "${builtins.head mr.bindWorkspaces}, default:true" ]
            ++
            builtins.map (w: "${w}, monitor:${mr.name}") mr.bindWorkspaces
          ))
          cfg.monitors.rules;

        general = {
          border_size = 1;
          gaps_in = 5;
          gaps_out = 10;
          "col.active_border" = "rgba(8620dfee)";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        input = {
          kb_layout = "us";
          # On us layouts, 
          kb_options = "caps:escape, compose:sclk";
          repeat_rate = 60;
          repeat_delay = 600;
          follow_mouse = 1;
        };

        dwindle = {
          preserve_split = true; # If false, resizing windows can change splits.
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
          };
        };

        animations = {
          enabled = true;
          bezier = [
            "standardBezier, 0.05, 0.9, 0.1, 1.05"
          ];
          animation = [
            "windows, 1, 4, standardBezier,"
            "windowsOut, 1, 4, default, popin 80%"
            "border, 1, 5, default"
            "borderangle, 1, 4, default"
            "fade, 1, 4, default"
            "workspaces, 1, 4, default"
          ];
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
      };
    };

    modules.home-manager.levi = {
      dunst.enable = cfg.integrateDunst;
      udiskie.enable = true; # for auto-mounting
      waybar.enable = true;
    };
  };
}
