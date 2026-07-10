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
      local launchers = {
        -- Steam UI has many components implemented as seperate windows. So match
        -- only main steam window so rest will open on main windows *current* workspace
        { initial_class = "steam", initial_title = "Steam" },
        { initial_class = ".*prismlauncher.*" },
        { initial_class = "r2modman" }
      }
      local games = {
        { initial_class = "steam_app_.*" },
        { initial_class = "gamescope" },
        { initial_class = ".*Minecraft.*" }
      }

      -- Make launchers open on designated workspace
      for _, launcher in ipairs(launchers) do
        hl.window_rule {
          match = launcher,
          workspace = launcherWorkspace
        }
      end
      -- Make games open on designated workspace silently, cuz games take time to launch
      for _, game in ipairs(games) do
        hl.window_rule {
          match = game,
          workspace = gamingWorkspace .. " silent",
          tag = "suppressInitialActivate"
        }
      end




      -- When not rendering, DbD tends to hang during transitions; annoying when queing for match
      hl.window_rule { match = { initial_title = "DeadByDaylight *" }, render_unfocused = true }
    '';
  };
}
