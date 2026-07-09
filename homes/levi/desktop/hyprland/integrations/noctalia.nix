{ config, lib, osConfig ? {}, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    modules.noctalia = {
      enable = true;
    };

    wayland.windowManager.hyprland.extraConfig = /* lua */ ''
      hl.on("hyprland.start", function ()
        hl.exec_cmd("noctalia")
      end)

      hl.layer_rule {
        name = "noctalia",
        match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$" },
        no_anim = true,
        blur = true,
        blur_popups = true,
        ignore_alpha = 0.5
      }

      local function noctBind(keys, cmd, flags)
        hl.bind(keys, DIS.exec_cmd("noctalia msg " .. cmd), flags or {})
      end
      -- UI toggles
      noctBind("SUPER + SPACE", "panel-toggle launcher")
      noctBind("SUPER + ALT + SPACE", "panel-toggle launcher /win")
      noctBind("ALT + TAB", "window-switcher")
      noctBind("SUPER + X", "panel-toggle clipboard")
      -- This does not currently exist in v5 but I assume it will eventually
      noctBind("SUPER + SHIFT + SPACE", "panel-toggle launcher /cmd")
      -- Media controls
      noctBind("XF86AudioPlay", "media toggle", { locked = true })
      noctBind("XF86AudioStop", "media stop", { locked = true })
      noctBind("XF86AudioNext", "media next", { locked = true })
      noctBind("XF86AudioPrev", "media previous", { locked = true })
      noctBind("SHIFT + XF86AudioNext", "media next-player", { locked = true })
      noctBind("SHIFT + XF86AudioPrev", "media previous-player", { locked = true })
      -- These 2 below do not currently exist in v5 but I assume something like them will eventually
      noctBind("XF86AudioForward", "media seekRelative 5", { locked = true })
      noctBind("XF86AudioRewind", "media seekRelative -5", { locked = true })
      -- System controls
      noctBind("XF86AudioRaiseVolume", "volume-up", { locked = true, repeating = true })
      noctBind("XF86AudioLowerVolume", "volume-down", { locked = true, repeating = true })
      noctBind("XF86AudioMute", "volume-mute", { locked = true })
      noctBind("XF86AudioMicMute", "mic-mute", { locked = true })
      ${ # If we didn't set brightness binds at the OS level (i.e. for builtin screens), then let Noctalia handle it
        let
          bctl = osConfig.modules.brightnessctl or {};
          osBinds = (bctl.enabled or false) && (bctl.brightnessKeys or false);
        in
        lib.optionalString (!osBinds) /* lua */ ''
          noctBind("XF86MonBrightnessUp", "brightness-up", { locked = true, repeating = true })
          noctBind("XF86MonBrightnessDown", "brightness-down", { locked = true, repeating = true })
        ''
      }
    '';
  };
}
