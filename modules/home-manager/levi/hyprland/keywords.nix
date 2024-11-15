{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland;
  toStr = builtins.toString;

  # Generate binds for windows between workspaces 1 through 10
  genNumWorkspaceBinds = mods: dispatcher: 
    builtins.genList (i: "${mods}, ${toStr (i + 1)}, ${dispatcher}, ${toStr (i + 1)}") 9 ++
    [ "${mods}, 0, ${dispatcher}, 10"];

  # Generate binds for dispatchers with direction parameters, bound to WASD.
  genDirectionBinds = mods: dispatcher: [
    "${mods}, W, ${dispatcher}, u"
    "${mods}, A, ${dispatcher}, l"
    "${mods}, S, ${dispatcher}, d"
    "${mods}, D, ${dispatcher}, r"
  ];
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
      "$mainMod" = "SUPER";

      bind = builtins.concatLists [
        # Generated general workspace binds
        (genNumWorkspaceBinds "$mainMod" "focusworkspaceoncurrentmonitor")
        (genNumWorkspaceBinds "$mainMod ALT" "workspace")
        (genNumWorkspaceBinds "$mainMod SHIFT" "movetoworkspace")
        (genNumWorkspaceBinds "$mainMod CTRL" "movetoworkspacesilent")

        # Generated general window binds
        (genDirectionBinds "$mainMod" "movefocus")
        (genDirectionBinds "$mainMod SHIFT" "movewindow")
        (genDirectionBinds "$mainMod CTRL" "swapwindow")

        [ # Other (non-generated) general binds
          "$mainMod, F, fullscreen"
          "$mainMod CTRL, F, togglefloating"
          "$mainMod, P, pin"
          
          "$mainMod ALT, C, killactive"
          "$mainMod ALT, BACKSPACE, exit"
          "$mainMod ALT, DELETE, exec, poweroff"
        ]

        [ # Application binds
          "$mainMod, T, exec, ${pkgs.kitty}/bin/kitty"
          "$mainMod, SPACE, exec, ${pkgs.ulauncher}/bin/ulauncher-toggle"
          "$mainMod, E, exec, ${pkgs.dolphin}/bin/dolphin"
          "$mainMod, B, exec, ${pkgs.firefox}/bin/firefox"
          "$mainMod, V, togglespecialworkspace, discord"
          "$mainMod, V, movetoworkspace, special:discord,class:(discord)$"
          "$mainMod, P, exec, XDG_CURRENT_DESKTOP=sway flameshot gui"
        ]
      ];

      # Mouse movement binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "workspace special:discord silent, class:(discord)"
        # "forceinput,class:^(ulauncher)$"
        "dimaround, class:(ulauncher)"
      ];

      exec-once = [
        # Utilities
        "systemctl --user start hyprpolkitagent"
        "${pkgs.hyprpaper}/bin/hyprpaper"
        "${pkgs.ulauncher}/bin/ulauncher --no-window-shadow --hide-window"

        # Ordinary applications
        "${pkgs.discord}/bin/discord"
      ] ++
      lib.optionals cfg.integrateDunst [ "${pkgs.dunst}/bin/dunst" ];
    };
}
