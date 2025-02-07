{ pkgs, config, lib, ... }:

let 
  cfg = config.modules.home-manager.levi.hyprland.integrations.discord;
in
{
  options.modules.home-manager.levi.hyprland.integrations.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Integrates Discord by setting up a special workspace for it.
      '';
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Starts Discord alongside Hyprland.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mainMod, V, togglespecialworkspace, discord"
        "$mainMod, V, movetoworkspace, special:discord,class:(discord)$"
      ];

      exec-once = lib.optionals cfg.autoStart [
        "${pkgs.discord}/bin/discord"
      ];

      windowrulev2 = [
        # Make discord start on its special workspace silently.
        "workspace special:discord silent, class:(discord)"
      ];
    };
  };
}
