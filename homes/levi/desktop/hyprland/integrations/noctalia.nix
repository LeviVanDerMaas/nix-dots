{ config, pkgs, lib, osConfig ? {}, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    modules.noctalia = {
      enable = true;
    };

    # Main config
    wayland.windowManager.hyprland.extraConfig = /* lua */ ''
      hl.on("hyprland.start", function ()
        hl.exec_cmd("noctalia")
      end)
      require("restart-updated-noctalia")

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
      -- noctBind("SUPER + SHIFT + SPACE", "panel-toggle launcher /cmd")
      -- Media controls
      noctBind("XF86AudioPlay", "media toggle", { locked = true })
      noctBind("XF86AudioStop", "media stop", { locked = true })
      noctBind("XF86AudioNext", "media next", { locked = true })
      noctBind("XF86AudioPrev", "media previous", { locked = true })
      noctBind("SHIFT + XF86AudioNext", "media next-player", { locked = true })
      noctBind("SHIFT + XF86AudioPrev", "media previous-player", { locked = true })
      -- For the below to v4 had a native IPC call for it, but v5 doesn't as of yet.
      hl.bind("XF86AudioForward", DIS.exec_raw("playerctl position 5+"), { locked = true, repeating = true })
      hl.bind("XF86AudioRewind", DIS.exec_raw("playerctl position 5-"), { locked = true, repeating = true })
      -- System controls
      noctBind("XF86AudioRaiseVolume", "volume-up", { locked = true, repeating = true })
      noctBind("XF86AudioLowerVolume", "volume-down", { locked = true, repeating = true })
      noctBind("XF86AudioMute", "volume-mute", { locked = true })
      noctBind("XF86AudioMicMute", "mic-mute", { locked = true })
      ${
        # If we didn't set brightness binds at the OS level (i.e. for builtin screens), then let Noctalia handle it
        let
          bctl = osConfig.modules.brightnessctl or {};
          osBinds = (bctl.enable or false) && (bctl.brightnessKeys.enable or false);
        in
        lib.optionalString (!osBinds) /* lua */ ''
          noctBind("XF86MonBrightnessUp", "brightness-up", { locked = true, repeating = true })
          noctBind("XF86MonBrightnessDown", "brightness-down", { locked = true, repeating = true })
          noctBind("SHIFT + XF86MonBrightnessUp", "brightness-up \\*", { locked = true, repeating = true })
          noctBind("SHIFT + XF86MonBrightnessDown", "brightness-down \\*", { locked = true, repeating = true })
        ''
      }
    '';

    # Upon config reload, check if the executable of the current running noctalia instance
    # is still at the same location as the one installed by the noctalia module. If not,
    # this implies that noctalia has been updated through Nix, so restart it.
    # NOTE: The reason this is in a seperate file in xdg config is that this lets us avoid
    # rebuilding the full hyprland config everytime Noctalia updates, by importing this
    # file via the config dir instead; then only this file is rebuilt upon noctalia updates.
    xdg.configFile."hypr/restart-updated-noctalia.lua".text =
      let
      restart-updated-noctalia = pkgs.writeShellScript "hyprland-restart-updated-noctalia" ''
        noctaliaPid=$(pidof -s noctalia) || exit 0
        # Gotta do it this cursed way with dirs instead of the executables directly,
        # because the direct executable obtained for the running instance is .noctalia-wrapped
        runningNoctaliaDir=$(dirname $(realpath /proc/"$noctaliaPid"/exe))
        pathNoctaliaDir=${config.programs.noctalia.package}/bin
        if [ "$runningNoctaliaDir" != "$pathNoctaliaDir" ]; then
          hyprctl notify 1 5000 0 "Noctalia: detected updated installation, starting updated executable!"
          kill "$noctaliaPid"
          sleep 1 # Give noctalia enough time to actually properly shutdown
          hyprctl eval "hl.exec_cmd('$pathNoctaliaDir/noctalia -d')"
        fi
        '';
      in
      /* lua */ ''
        hl.on("config.reloaded", function ()
          hl.exec_cmd("${restart-updated-noctalia}")
        end)
      '';
  };
}
