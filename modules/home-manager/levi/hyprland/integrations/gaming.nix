{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland.integrations.gaming;
  gws = "game";
  sws = "steam";
  initialGameClasses = [
    "steam_app_.*"
    "gamescope"
    ".*prismlauncher.*"
    ".*Minecraft.*"
  ];
in
{
  options.modules.home-manager.levi.hyprland.integrations.gaming = {
    enable = lib.mkEnableOption ''
      Makes a special gaming workspace for games and puts Steam on a
      special workspace. Both workspaces are controlled with the same key,
      where the Steam workspace will open if the gaming workspace is already open
      or there is nothing on the gaming workspace.
    '';
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      workspace = [
        "name:${gws}, on-created-empty:hyprctl dispatch workspace special:${sws}"
        "special:${sws}, on-created-empty:steam"
      ];

      windowrule = [
        "workspace special:${sws} silent, initialClass:(steam)"
        "pin, title:(), class:(steam)" # Hack for steam subwindows refusing to go on special ws.
      ] ++ builtins.map (c: "workspace name:${gws} silent, initialClass:(${c})") initialGameClasses;


      bind = [
        # If our gaming workspace is already active we toggle the steam workspace
        "$mainMod, G, exec, ${pkgs.writeShellScript "hyprGameWorkspaceToggler" ''
          if [ "$(hyprctl -j activeworkspace | ${pkgs.jq}/bin/jq -r .name)" != "${gws}" ]; then
            hyprctl dispatch workspace name:${gws}
          else
            hyprctl dispatch togglespecialworkspace ${sws}
          fi
        ''}"
        "$mainMod, G, movetoworkspace, special:${sws},class:(steam)"
      ];
    };
  };
}
