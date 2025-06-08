{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  imports = [
    ./animations.nix
    ./binds.nix
    ./exec.nix
    ./hyprpaper.nix
    ./monitors.nix

    ./integrations
  ];

  options.modules.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      blueberry # simple bluetooth control
      hyprpolkitagent
      ulauncher
    ];

    modules = {
      dunst.enable = true;
      udiskie.enable = true; # for auto-mounting
      waybar.enable = true;
    };

    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.settings = {
      input = {
        kb_layout = "us";
        kb_options = "caps:escape, compose:sclk";
        repeat_rate = 60;
        repeat_delay = 600;
        follow_mouse = 1;
      };

      general = {
        border_size = 1;
        gaps_in = 5;
        gaps_out = 10;
        "col.active_border" = "rgba(8620dfee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
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

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      windowrule = [
        "dimaround, class:(ulauncher)"
      ];
    };
  };
}
