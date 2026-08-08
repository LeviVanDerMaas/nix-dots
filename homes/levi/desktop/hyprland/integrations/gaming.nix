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
        { initial_class = "steam_app_.*" }, -- Catches most, but not ALL steam games
        { initial_class = "gamescope" },
        { initial_class = ".*Minecraft.*" }
      }

      for _, launcher in ipairs(launcherWindows) do
        hl.window_rule { match = launcher, tag = "gameLauncher" }

        -- Make launchers main windows open on designated workspace and call attention
        hl.window_rule {
          match = launcher,
          workspace = launcherWorkspace
        }
      end
      for _, automaticLauncher in ipairs(automaticLauncherWindows) do
        -- Make "automatic" launcher windows open on designated workspace silently;
        -- Many launchers have these for things like sign-in/update/shutdown progress,
        -- or launchers embedded in other launchers (ugh).
        -- NOTE: Some launchers may still call focus to their main window, like Steam on shutdown
        hl.window_rule {
          match = automaticLauncher,
          workspace = launcherWorkspace .. " silent",
          tag = "suppressInitialActivate"
        }
      end
      for _, game in ipairs(gameWindows) do
        hl.window_rule { match = game, tag = "game" }

        -- Make games open on designated workspace silently, cuz games take time to launch
        hl.window_rule {
          match = game,
          workspace = gamingWorkspace .. " silent",
          tag = "suppressInitialActivate"
        }
      end

      -- If a game opens while the currently focussed window is a launcher,
      -- then call the focus to that game window despite the silent opening
      -- NOTE: For some weird reason this won't work with `window.open`, in that case
      -- it will just refocus the already window (confirmed it's not because of other config).
      hl.on("window.open_early", function(w)
        local active_window = hl.get_active_window()
        if not active_window then
          return
        end
        local opened_tags = w.tags
        local active_tags = active_window.tags
        local game_opened_while_launcher_active = (opened_tags and active_tags)
          and (active_tags == "gameLauncher*" or array_indexOf(active_tags, "gameLauncher*"))
          and (opened_tags == "game*" or array_indexOf(opened_tags, "game*"))
        if game_opened_while_launcher_active then
          hl.dispatch(DIS.focus { window = w })
        end
      end)





      -- GAME SPECIFIC
      -- When not rendering, DbD tends to hang during scene transitions; annoying when queing for match
      hl.window_rule { match = { initial_title = "DeadByDaylight *" }, render_unfocused = true }
    '';
  };
}
