{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  wayland.windowManager.hyprland.extraConfig = lib.mkOrder 1 /* lua */ ''
    DIS = hl.dsp
    WIN = hl.dsp.window
    WS = hl.dsp.workspace


    -- Does not deal with or consider metatables or recursive tables.
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
  '';
}
