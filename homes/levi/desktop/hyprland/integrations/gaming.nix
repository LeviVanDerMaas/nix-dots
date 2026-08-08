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
      -- TODO: Check if this is fixed and then remove it (last checked 2026-07-10)
      hl.on("hyprland.start", function ()
        hl.exec_cmd("systemctl --user restart pipewire pipewire-pulse wireplumber")
      end)

      local launcherWorkspace = "${toString cfg.launcherWorkspace}"
      local gamingWorkspace = "${toString cfg.gamingWorkspace}"
      local launcherWindows = {
        -- Steam UI has many components implemented as seperate windows. So match
        -- only main steam window so rest will open on main windows *current* workspace
        { initial_class = "steam", initial_title = "Steam" },
        { initial_class = ".*prismlauncher.*" },
        { initial_class = "r2modman" }
      }
      local automaticLauncherWindows = {
        { initial_class = "steam", initial_title = "(Sign in to Steam)|(Shutdown)"},
        { initial_class = "", initial_title = "Steam"} -- Steam updater window
      }
      local gameWindows = {
        { initial_class = "steam_app_.*" },
        { initial_class = "gamescope" },
        { initial_class = ".*Minecraft.*" }
      }

      -- Make launchers main windows open on designated workspace and call attention
      for _, launcher in ipairs(launcherWindows) do
        hl.window_rule {
          match = launcher,
          workspace = launcherWorkspace
        }
      end
      -- Make "automatic" launcher windows open on designated workspace silently;
      -- Many launchers have these for things like sign-in/update/shutdown progress,
      -- or launchers embedded in other launchers (ugh).
      -- NOTE: Some launchers may still call focus to their main window, like Steam on shutdown
      for _, automaticLauncher in ipairs(automaticLauncherWindows) do
        hl.window_rule {
          match = automaticLauncher,
          workspace = launcherWorkspace .. " silent",
          tag = "suppressInitialActivate"
        }
      end
      -- Make games open on designated workspace silently, cuz games take time to launch
      for _, game in ipairs(gameWindows) do
        hl.window_rule {
          match = game,
          workspace = gamingWorkspace .. " silent",
          tag = "suppressInitialActivate"
        }
      end



      -- GAME SPECIFIC
      -- When not rendering, DbD tends to hang during scene transitions; annoying when queing for match
      hl.window_rule { match = { initial_title = "DeadByDaylight *" }, render_unfocused = true }
    '';
  };
}
