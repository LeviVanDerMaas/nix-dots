{ config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = /* lua */ ''
      hl.window_rule { -- Pavucontrol
        match = { initial_class = "org.pulseaudio.pavucontrol"},
        float = true, center = true
      }
      hl.window_rule { -- nm-connection-editor, a.k.a nm-applet's GUI
        match = { initial_class = "nm-connection-editor"},
        float = true, center = true
      }

      -- Windows with a DYNAMIC "suppessInitialActivates" tag will upon opening disable
      -- focus_on_activate requests briefly, before this is reset to the global default.
      -- Mainly useful to silently open windows that request activation upon opening.
      hl.on("window.open", function(w)
        local SIA_tag = "suppressInitialActivate*"
        local tags = w.tags
        if not (tags == SIA_tag or tbl_contains(tags, SIA_tag)) then
          return 
        end

        local setWinFOA = function (v) -- v should be a string
          return WIN.set_prop { window = w, prop = "focus_on_activate", value = v }
        end

        hl.dispatch(setWinFOA("false"))
        hl.timer(function ()
          if not w.stable_id then
            return -- Window has expired already
            -- WARNING: Relies on undocumented feature that fields of expired windows become nil
          end

          local globalFOA = tostring(hl.get_config("misc.focus_on_activate"))
          hl.dispatch(setWinFOA(globalFOA))
        end, { timeout = 3000, type = "oneshot" })
      end)
    '';
  };
}
