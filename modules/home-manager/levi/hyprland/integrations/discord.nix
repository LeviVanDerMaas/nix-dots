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
      default = false;
      description = ''
        Starts Discord alongside Hyprland.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = let
      discordExe = "${pkgs.discord}/bin/discord";
    in {
      workspace = [
        "special:discord, on-created-empty:${discordExe}"
      ];

      windowrulev2 = [
        "workspace special:discord silent, class:(discord)"
      ];

      exec-once = lib.optionals cfg.autoStart [
        discordExe
      ];

      bind = [
        "$mainMod, V, togglespecialworkspace, discord"
        "$mainMod, V, movetoworkspace, special:discord,class:(discord)$"
      ];
    };
  };
}
