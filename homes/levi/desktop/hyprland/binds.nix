{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = lib.mkOrder 20 /* lua */ ''
      -- Generate binds for each digit key (0 to 9).
      -- For each digit key, set specified dispatcher parameters to value corresponding the key (0 maps to 10).
      -- `config` is a table of the following optional values:
      --    * digitParams: list of dispatcher parameters for which to set digits (default { "workspace" })
      --    * extraParams: table of extra parameters to set for the dispatcher and their values
      --    * flags: bind flags to set
      --    * digitPrefix: string to prefix to the digit for each bind (e.g. for relative workspace ids)
      local function genDigitBinds(mods, dispatcher, config)
        config = config or {}
        local digitParams = config.digitParams or { "workspace" }
        local extraParams = config.extraParams or {}
        local flags = config.flags or {}
        local digitPrefix = config.digitPrefix or ""

        local dspParams = tbl_deepclone(extraParams)
        for d = 1, 9 do
          for _, p in ipairs(digitParams) do dspParams[p] = digitPrefix .. d end
          hl.bind(mods .. " + " .. d, dispatcher(dspParams), flags)
        end
        for _, p in ipairs(digitParams) do dspParams[p] = digitPrefix .. 10 end
        hl.bind(mods .. " + " .. 0, dispatcher(dspParams), flags)
      end

      local directions = {
         K = "u"; W = "u"; UP    = "u";
         H = "l"; A = "l"; LEFT  = "l";
         J = "d"; S = "d"; DOWN  = "d";
         L = "r"; D = "r"; RIGHT = "r";
      }
      -- Generate binds for various directional keys (HJKL, WASD, arrow keys).
      -- For each key, set the dispatcher's specified parameters to value corresponding to the key.
      -- `config` is a table of the following optional values:
      --   * directionParams: list of dispatcher parameters for which to set the direction ( default { "direction" })
      --   * extraParams: table of extra parameters to set for the dispatcher and their values
      --   * flags: bind flags to set
      local function genDirectionBinds(mods, dispatcher, config)
        config = config or {}
        local directionParams = config.directionParams or { "direction" }
        local extraParams = config.extraParams or {}
        local flags = config.flags or {}

        local dspParams = tbl_deepclone(extraParams)
        for k, d in pairs(directions) do
          for _, p in ipairs(directionParams) do dspParams[p] = d end
          hl.bind(mods .. " + " .. k, dispatcher(dspParams), flags)
        end
      end





      -- Workspace binds
      genDigitBinds("SUPER", dispatcher_map1to10toUniqueIdForMon(DIS.focus))
      genDigitBinds("SUPER + SHIFT", dispatcher_map1to10toUniqueIdForMon(WIN.move), { extraParams = { follow = true } })
      genDigitBinds("SUPER + CTRL", dispatcher_map1to10toUniqueIdForMon(WIN.move), { extraParams = { follow = false } })
      -- This is a simpler form of the below binds that should work starting from Hyprland 0.66.
      -- Currently, hl.get_workspace() does not support workspace selectors besides id, but
      -- the following PR adds that: https://github.com/hyprwm/Hyprland/pull/15555
      -- genDigitBinds("SUPER + ALT",
      --   dispatcher_map1to10toUniqueIdForMon(workspace_swap_id_and_move, "id"),
      --   { digitParams = { "id" }, extraParams = { workspace = "+0", follow = true } }
      -- )
      local digit_swap_dispatcher = dispatcher_map1to10toUniqueIdForMon(
        function(params)
          params = tbl_deepclone(params)
          params.workspace = hl.get_active_workspace()
          hl.dispatch(workspace_swap_id_and_move(params))
        end,
        "id"
      )
      local direction_swap_dispatcher = function(params)
        params = tbl_deepclone(params)
        return function()
          local dParams = tbl_deepclone(params)
          dParams.workspace = hl.get_active_workspace()
          hl.dispatch(workspace_swap_id_and_monitor(dParams))
        end
      end
      genDigitBinds("SUPER + ALT", digit_swap_dispatcher, { digitParams = { "id" }, extraParams = { follow = true } })
      genDigitBinds("SUPER + ALT + CTRL", digit_swap_dispatcher, { digitParams = { "id" }, extraParams = { follow = false } })
      genDirectionBinds("SUPER + ALT", direction_swap_dispatcher, { directionParams = { "monitor" }, extraParams = { follow = true }} )
      genDirectionBinds("SUPER + ALT + CTRL", direction_swap_dispatcher, { directionParams = { "monitor" }, extraParams = { follow = false }} )
      hl.bind("SUPER + mouse_down", DIS.focus({ workspace = "r-1" }))
      hl.bind("SUPER + mouse_up", DIS.focus({ workspace = "r+1" }))

      -- Monitor binds
      hl.bind("SUPER + TAB", DIS.focus { monitor = "+1" })
      hl.bind("SUPER + SHIFT + TAB", DIS.focus { monitor = "-1" })
      hl.bind("SUPER + mouse_left", DIS.focus({ monitor = "l" }))
      hl.bind("SUPER + mouse_right", DIS.focus({ monitor = "r" }))

      -- Window binds
      genDirectionBinds("SUPER", DIS.focus)
      genDirectionBinds("SUPER + SHIFT", WIN.move)
      genDirectionBinds("SUPER + CTRL", WIN.swap)
      -- Mouse binds
      hl.bind("SUPER + mouse:272", WIN.drag(), { mouse = true })
      hl.bind("SUPER + mouse:273", WIN.resize(), { mouse = true })
      -- Split management
      hl.bind("SUPER + PERIOD", DIS.layout("splitratio +0.1"))
      hl.bind("SUPER + COMMA",  DIS.layout("splitratio -0.1"))
      hl.bind("SUPER + R",  DIS.layout("swapsplit"))
      hl.bind("SUPER + SHIFT + R",  DIS.layout("togglesplit")) -- Requires preserve_split to be true
      -- Screenstate management
      hl.bind("SUPER + F", WIN.fullscreen({ mode = "fullscreen", action = "toggle" }))
      hl.bind("SUPER + SHIFT + F", WIN.fullscreen({ mode = "maximized", action = "toggle" }))
      -- Floating management
      hl.bind("SUPER + Z", WIN.float({ action = "toggle" }))
      hl.bind("SUPER + SHIFT + Z", WIN.center())
      hl.bind("SUPER + ALT + Z", WIN.pin())
      -- Kill binds
      hl.bind("SUPER + ALT + C", WIN.close())
      hl.bind("SUPER + SHIFT + CTRL + ALT + C", WIN.kill())

      -- Application binds
      hl.bind("SUPER + T", DIS.exec_cmd("kitty"))
      hl.bind("SUPER + E", DIS.exec_cmd("dolphin"))
      hl.bind("SUPER + B", DIS.exec_cmd("firefox"))
      hl.bind("SUPER + SHIFT + B", DIS.exec_cmd("firefox --private-window"))
    '';
  };
}
