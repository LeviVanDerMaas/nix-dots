{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  wayland.windowManager.hyprland.extraConfig = lib.mkOrder 0 /* lua */ ''
    MAX_NUMERICAL_WORKSPACE = 0x7FFFFFFF
    DIS = hl.dsp
    WIN = hl.dsp.window
    WS = hl.dsp.workspace

    -- Useful for runtime debugging
    function debug_notify(msg, duration)
      hl.notification.create { text = tostring(msg), timeout = duration or 5000, icon = 1 }
    end

    -- Return the index of an element in an array or nil if not found; does not account for metatables.
    function array_indexOf(array, e)
      for i, v in ipairs(array) do
        if e == v then return i end
      end
      return nil
    end

    -- Check if a table contains a value; does not account for metatables.
    function tbl_contains(tbl, e)
      for _, v in pairs(tbl) do
        if e == v then return true end
      end
      return false
    end

    -- Deep clones a table; does not deal with or consider metatables or recursive tables.
    function tbl_deepclone(tbl)
      local dup = {}
      for k, v in pairs(tbl) do
        if type(v) ~= "table" then
          dup[k] = v
        else
          dup[k] = tbl_deepclone(v)
        end
      end
      return dup
    end

    -- Finds a free numerical workspace id to use, starting from the highest possible.
    function find_free_workspace_id()
      for wsid=MAX_NUMERICAL_WORKSPACE, 1, -1 do
        if not hl.get_workspace(wsid) then
          return wsid
        end
      end
      return nil
    end
  '';
}
