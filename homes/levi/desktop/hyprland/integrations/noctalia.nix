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
      targetDesktops = "Hyprland";
    };

    wayland.windowManager.hyprland.settings = {
      bind = genNoctCalls [
        [ "$mainMod" "SPACE" "launcher toggle" ]
        [ "$mainMod SHIFT" "SPACE" "launcher command" ]
        [ "$mainMod ALT" "SPACE" "launcher windows" ]
        [ "$mainMod" "X" "launcher clipboard" ]
      ];

      bindel = genNoctCalls ([
        [ "" "XF86AudioRaiseVolume" "volume increase || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" ]
        [ "" "XF86AudioLowerVolume" "volume decrease || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" ]
        [ "" "XF86AudioMute" "volume muteOutput || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ]
        [ "" "XF86AudioMicMute" "volume muteInput || wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ]

        [ "" "XF86AudioPlay" "media playPause"]
        [ "" "XF86AudioStop" "media pause"]
        [ "" "XF86AudioNext" "media next" ]
        [ "" "XF86AudioPrev" "media previous" ]
        [ "" "XF86AudioForward" "media seekRelative 5" ]
        [ "" "XF86AudioRewind" "media seekRelative -5" ]
      ] ++ (
        let
          bctl = osConfig.modules.brightnessctl or {};
          osBinds = (bctl.enabled or false) && (bctl.brightnessKeys or false);
        in
        lib.optionals (!osBinds) [
          [ "" "XF86MonBrightnessUp" "brightness increase" ]
          [ "" "XF86MonBrightnessDown" "brightness decrease" ]
        ]
      ));
    };
  };
}
