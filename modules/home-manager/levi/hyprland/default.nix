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
    home.packages = with pkgs; [
      grimblast
      hyprpolkitagent
      hyprpicker
      ulauncher
    ];

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        # When you set envs with this, Hyprland source code will use `systemctl --user import-environment`
        # and `dbus-update-activation-environment --systemd` and cpp's `setenv()` to set and propagate these
        # vars properly. This may cause these env vars to also be imported on start when switching to other DE/WM sessions
        # during the same boot, depending on what these DE/WM's do when they start up. This can cause issues for certain
        # DE/WM's depending on what env vars you set, so keep that in mind. Whether this is bad on
        # Hyprland because of the way it sets things up or other sessions because they expect certain values to be unset,
        # I don't know. Trying to fix this was a massive headache, and def not worth it as you can just reboot, so I gave up on that.
        env = [
          "QT_QPA_PLATFORMTHEME,gtk2" # Plasma DE will fail to start after setting this to gtk2, restart fixes this.
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
      udiskie.enable = true; # for auto-mounting
      waybar.enable = true;
    };
  };
}
