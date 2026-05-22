{ config, lib, fns, osConfig ? {}, ... }:

let
  cfg = config.modules.hyprland;
  noctCall = mods: key: cmd: "${mods}, ${key}, exec, noctalia-shell ipc call ${cmd}";
  genNoctCalls = map (fns.apply noctCall);
in
{
  config = lib.mkIf cfg.enable {
    modules.noctalia-shell = {
      enable = true;
    };

    wayland.windowManager.hyprland.extraConfig = /* lua */ ''
      hl.on("hyprland.start", function () 
        hl.exec_cmd("noctalia-shell")
      end)
      
      local function noctCall(keys, cmd, flags)
        flags = flags or {}
        hl.bind(keys, DIS.exec_cmd("noctalia-shell ipc call " .. cmd), flags)
      end
      noctCall("SUPER + SPACE", "launcher toggle")
      noctCall("SUPER + SHIFT + SPACE", "launcher command")
      noctCall("SUPER + ALT + SPACE", "launcher windows")
      noctCall("SUPER + X", "launcher clipboard")

      local function noctCallEl(keys, cmd)
        noctCall(keys, cmd, { repeating = true, locked = true })
      end
      noctCallEl("XF86AudioRaiseVolume", "volume increase || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
      noctCallEl("XF86AudioLowerVolume", "volume decrease || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
      noctCallEl("XF86AudioMute", "volume muteOutput || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
      noctCallEl("XF86AudioMicMute", "volume muteInput || wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
      noctCallEl("XF86AudioPlay", "media playPause")
      noctCallEl("XF86AudioStop", "media pause")
      noctCallEl("XF86AudioNext", "media next")
      noctCallEl("XF86AudioPrev", "media previous")
      noctCallEl("XF86AudioForward", "media seekRelative 5")
      noctCallEl("XF86AudioRewind", "media seekRelative -5")

      ${
        let
          bctl = osConfig.modules.brightnessctl or {};
          osBinds = (bctl.enabled or false) && (bctl.brightnessKeys or false);
        in
        lib.optionalString (!osBinds) /* lua */ ''
          noctCallEl("XF86MonBrightnessUp", "brightness increase")
          noctCallEl("XF86MonBrightnessDown", "brightness decrease")
        ''
      }
    '';
  };
}
