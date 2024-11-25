{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.home-manager.levi.hyprland;
in
{
  imports = [
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
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Just the list that you would pass into 
        `wayland.windowManager.hyprland.settings.monitor`.
        Reason it is a seperate model is because this is very much
        system-dependent, so this lets you configure it at a per-system
        level.
      '';
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
    wayland.windowManager.hyprland = {
      enable = true;
       
      settings = {
        env = [
          "QT_QPA_PLATFORMTHEME,qt5ct"
        ];

        general = {
          border_size = 1;
          gaps_in = 5;
          gaps_out = 10;
          "col.active_border" = "rgba(8620dfee)";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        monitor = cfg.monitors;

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
      waybar.enable = true;
    };

    home.packages = with pkgs; [
      grimblast
      hyprpolkitagent
      hyprpicker
      ulauncher
    ];
  };
}
