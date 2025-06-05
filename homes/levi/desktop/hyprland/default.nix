{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  imports = [
    ./integrations
    ./binds.nix
    ./exec.nix
    ./hyprpaper.nix
    ./windowrules.nix
  ];

  options.modules.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
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
            [ "${builtins.toString (builtins.head mr.bindWorkspaces)}, default:true" ]
            ++
            builtins.map (w: "${builtins.toString w}, monitor:${mr.name}") mr.bindWorkspaces
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

    modules = {
      dunst.enable = cfg.integrateDunst;
      udiskie.enable = true; # for auto-mounting
      waybar.enable = true;
    };
  };
}
