{ config, lib, ... }:

let
  cfg = config.modules.hyprland.integrations.gaming;
in
{
  options.modules.hyprland.integrations.gaming = {
    enable = lib.mkEnableOption ''
      Integration for games.
    '';
    launcherWorkspace = lib.mkOption {
      type = lib.types.either lib.types.int lib.types.str;
      default = 4;
      description = "Which workspace to designate as the launcher workspace";
    };
    gamingWorkspace = lib.mkOption {
      type = lib.types.either lib.types.int lib.types.str;
      default = 5;
      description = "Which workspace to designate as the gaming workspace";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = /* lua */ ''
      local initialLauncherClasses = { "steam", ".*prismlauncher.*" }
      local initialGameClasses = { "steam_app_.*", "gamescope", ".*Minecraft.*" }
      local launcherWorkspace = "${toString cfg.launcherWorkspace}"
      local gamingWorkspace = "${toString cfg.gamingWorkspace}"

      -- Make launchers open on designated workspace
      for _, lc in ipairs(initialLauncherClasses) do
        hl.window_rule {
          match = { initial_class = lc },
          workspace = launcherWorkspace
        }
      end
      -- Make games open on designated workspace silently
      for _, gc in ipairs(initialGameClasses) do
        hl.window_rule {
          match = { initial_class = gc },
          workspace = gamingWorkspace .. " silent"
        }
      end
    '';
  };
}
