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

      local function noctBind(keys, cmd, flags)
        hl.bind(keys, DIS.exec_cmd("noctalia msg " .. cmd), flags or {})
      end
      local function noctBind_fLocked(keys, cmd)
        noctBind(keys, cmd, { locked = true })
      end

      -- UI toggles
      noctBind("SUPER + SPACE", "panel-toggle launcher")
      noctBind("SUPER + ALT + SPACE", "panel-toggle launcher /win")
      noctBind("ALT + TAB", "window-switcher")
      noctBind("SUPER + X", "panel-toggle clipboard")
      -- This does not currently exist in v5 but I assume it will eventually
      noctBind("SUPER + SHIFT + SPACE", "panel-toggle launcher /cmd")

      -- Media controls
      noctBind_fLocked("XF86AudioPlay", "media toggle")
      noctBind_fLocked("XF86AudioStop", "media stop")
      noctBind_fLocked("XF86AudioNext", "media next")
      noctBind_fLocked("XF86AudioPrev", "media previous")
      noctBind_fLocked("SHIFT + XF86AudioNext", "media next-player")
      noctBind_fLocked("SHIFT + XF86AudioPrev", "media previous-player")
      -- These 2 below do not currently exist in v5 but I assume something like them will eventually
      noctBind_fLocked("XF86AudioForward", "media seekRelative 5")
      noctBind_fLocked("XF86AudioRewind", "media seekRelative -5")

      -- System controls
      noctBind_fLocked("XF86AudioRaiseVolume", "volume-up")
      noctBind_fLocked("XF86AudioLowerVolume", "volume-down")
      noctBind_fLocked("XF86AudioMute", "volume-mute")
      noctBind_fLocked("XF86AudioMicMute", "mic-mute")
      ${ # If we didn't set brightness binds at the OS level (i.e. for builtin screens), then let Noctalia handle it
        let
          bctl = osConfig.modules.brightnessctl or {};
          osBinds = (bctl.enabled or false) && (bctl.brightnessKeys or false);
        in
        lib.optionalString (!osBinds) /* lua */ ''
          noctBind_fLocked("XF86MonBrightnessUp", "brightness-up")
          noctBind_fLocked("XF86MonBrightnessDown", "brightness-down")
        ''
      }
    '';
  };
}
