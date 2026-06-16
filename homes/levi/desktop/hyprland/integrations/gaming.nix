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
      -- Temporary workaround for apparent Pipewire regression causing Steam to segfault on launch
      -- https://github.com/ValveSoftware/steam-for-linux/issues/13174
      -- TODO: Check if this is fixed and then remove it
      hl.on("hyprland.start", function ()
        hl.exec_cmd("systemctl --user restart pipewire pipewire-pulse wireplumber")
      end)

      local initialLauncherClasses = { "steam", ".*prismlauncher.*", "r2modman" }
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

      -- Make games open on designated workspace silently, cuz games take time to launch
      for _, gc in ipairs(initialGameClasses) do
        hl.window_rule {
          match = { initial_class = gc },
          workspace = gamingWorkspace .. " silent",
          tag = "suppressInitialActivate"
        }
      end




      -- When not rendering, DbD tends to hang during transitions; annoying when queing for match
      hl.window_rule { match = { initial_title = "DeadByDaylight *" }, render_unfocused = true }
    '';
  };
}
