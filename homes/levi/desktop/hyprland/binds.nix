{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    # Make sure binds are set early in final config file so that they still
    # work even if a later part of the config fails
    wayland.windowManager.hyprland.extraConfig = lib.mkBefore /* lua */ ''
      -- Generate workspace-related binds for each digit key (0 to 9).
      -- For each digit, set dispatcher's 'workspace' field to value corresponding the key, with 0 -> 10.
      -- prefixDigit: string to prefix to workspace selector
      local function genWorkspaceDigitBinds(mods, dispatcher, prefixDigit, params, flags)
        prefixDigit = prefixDigit or ""
        params = params and tbl_deepclone(params) or {}
        flags = flags or {}
        for d = 1, 9 do
          params.workspace = prefixDigit .. d
          hl.bind(mods .. " + " .. d, dispatcher(params), flags)
        end
        params.workspace = prefixDigit .. 10
        hl.bind(mods .. " + " .. 0, dispatcher(params), flags)
      end

      local directions = {
         K = "u"; W = "u"; UP    = "u";
         H = "l"; A = "l"; LEFT  = "l";
         J = "d"; S = "d"; DOWN  = "d";
         L = "r"; D = "r"; RIGHT = "r";
      }
      -- Generate directional binds. For each key, set the dispatcher's
      -- 'direction' field to the value mapped to that key. If 'params.monitor'
      -- evaluates to true, set that instead.
      local function genDirectionBinds(mods, dispatcher, params, flags)
        params = params and tbl_deepclone(params) or {}
        flags = flags or {}
        for k, v in pairs(directions) do
          if params.monitor then
            params.monitor = v
          else
            params.direction = v
          end
          hl.bind(mods .. " + " .. k, dispatcher(params), flags)
        end
      end



      -- Workspace binds
      local function genWorkspaceDigitBinds_rAbs(mods, dispatcher, params, flags)
        genWorkspaceDigitBinds(mods, dispatcher, "r~", params, flags)
      end
      genWorkspaceDigitBinds_rAbs("SUPER", DIS.focus)
      genWorkspaceDigitBinds_rAbs("SUPER + SHIFT", WIN.move, { follow = true })
      genWorkspaceDigitBinds_rAbs("SUPER + CTRL", WIN.move, { follow = false })
      hl.bind("SUPER + mouse_down", DIS.focus({ workspace = "r-1" }))
      hl.bind("SUPER + mouse_up", DIS.focus({ workspace = "r+1" }))

      -- Monitor binds
      genDirectionBinds("SUPER + ALT", DIS.focus, { monitor = true })
      genDirectionBinds("SUPER + ALT + SHIFT", WIN.move, { monitor = true, follow = true })
      genDirectionBinds("SUPER + ALT + CTRL", WIN.move, { monitor = true, follow = false })
      hl.bind("SUPER + ALT + ALT_L", DIS.focus { monitor = "+1" }, { release = "true" })
      hl.bind("SUPER + TAB", DIS.focus { monitor = "+1" }) -- Alternative to above for standard keyboard
      hl.bind("SUPER + mouse_left", DIS.focus({ monitor = "l" }))
      hl.bind("SUPER + mouse_right", DIS.focus({ monitor = "r" }))

      -- Window binds
      genDirectionBinds("SUPER", DIS.focus)
      genDirectionBinds("SUPER + SHIFT", WIN.move)
      genDirectionBinds("SUPER + CTRL", WIN.swap)
      -- Mouse binds
      hl.bind("SUPER + mouse:272", WIN.drag(), { mouse = true })
      hl.bind("SUPER + mouse:273", WIN.resize(), { mouse = true })
      -- Split management (Dwindle layout)
      -- hl.bind("SUPER + PERIOD", DIS.layout("splitratio +0.1"))
      -- hl.bind("SUPER + COMMA",  DIS.layout("splitratio -0.1"))
      -- hl.bind("SUPER + R",  DIS.layout("swapsplit"))
      -- hl.bind("SUPER + SHIFT + R",  DIS.layout("togglesplit")) -- Requires preserve_split to be true
      -- Column management (Scrolling layout)
      hl.bind("SUPER", DIS.layout(""))
      hl.bind("SUPER + PERIOD", DIS.layout("colresize +0.1"))
      hl.bind("SUPER + COMMA",  DIS.layout("colresize -0.1"))
      hl.bind("SUPER + R",  DIS.layout("swapcol r"))
      hl.bind("SUPER + SHIFT + R",  DIS.layout("swapcol l"))
      hl.bind("SUPER + Q",  DIS.layout("consume_or_expel next"))
      hl.bind("SUPER + SHIFT + Q",  DIS.layout("consume_or_expel prev"))

      -- Screenstate management
      hl.bind("SUPER + F", WIN.fullscreen({ mode = "fullscreen", action = "toggle" }))
      -- hl.bind("SUPER + SHIFT + F", WIN.fullscreen({ mode = "maximized", action = "toggle" })) -- Acts as colresize 1.0 for scrolling
      hl.bind("SUPER + SHIFT + F", DIS.layout("colresize +conf"))
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
