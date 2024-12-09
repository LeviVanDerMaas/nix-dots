{ pkgs, config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland;
  toStr = builtins.toString;

  # Generate binds for windows between workspaces 1 through 10
  genNumBinds = mods: dispatcher: 
    builtins.genList (i: "${mods}, ${toStr (i + 1)}, ${dispatcher}, ${toStr (i + 1)}") 9 ++
    [ "${mods}, 0, ${dispatcher}, 10"];

  # Generate binds for dispatchers with direction parameters.
  genDirectionBinds = mods: dispatcher: [
    "${mods}, W, ${dispatcher}, u"
    "${mods}, A, ${dispatcher}, l"
    "${mods}, S, ${dispatcher}, d"
    "${mods}, D, ${dispatcher}, r"

    "${mods}, UP, ${dispatcher}, u"
    "${mods}, LEFT, ${dispatcher}, l"
    "${mods}, DOWN, ${dispatcher}, d"
    "${mods}, RIGHT, ${dispatcher}, r"

    "${mods}, H, ${dispatcher}, l"
    "${mods}, J, ${dispatcher}, d"
    "${mods}, K, ${dispatcher}, u"
    "${mods}, L, ${dispatcher}, r"
  ];
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    "$mainMod" = "SUPER";

    bind = builtins.concatLists [
      # Generated general workspace binds
      (genNumBinds "$mainMod" "workspace")
      (genNumBinds "$mainMod SHIFT" "movetoworkspace")
      (genNumBinds "$mainMod CTRL" "movetoworkspacesilent")
      (genNumBinds "$mainMod ALT" "focusworkspaceoncurrentmonitor")

      # Generated general window binds
      (genDirectionBinds "$mainMod" "movefocus")
      (genDirectionBinds "$mainMod SHIFT" "movewindow")
      (genDirectionBinds "$mainMod CTRL" "swapwindow")

      [ 
        # Other (non-generated) general binds
        "$mainMod, F, fullscreen"

        "$mainMod SHIFT, F, togglefloating"
        "$mainMod, P, pin"
        "$mainMod, C, centerwindow"

        "$mainMod, Q, togglesplit"
        "$mainMod SHIFT, Q, swapsplit"
        
        # Screenshots
        " , PRINT, exec, grimblast copy output"
        "$mainMod, PRINT, exec, grimblast copy area"
        "$mainMod SHIFT, PRINT, exec, grimblast copy screen"
        "$mainMod CTRL, PRINT, exec, hyprpicker -anf hex"

        # Killing binds
        "$mainMod ALT, C, killactive"
        "$mainMod SHIFT CTRL ALT, E, exit"
        "$mainMod SHIFT CTRL ALT, P, exec, poweroff"

        # Application binds
        "$mainMod, T, exec, ${pkgs.kitty}/bin/kitty"
        "$mainMod, SPACE, exec, ${pkgs.ulauncher}/bin/ulauncher-toggle"
        "$mainMod, E, exec, ${pkgs.dolphin}/bin/dolphin --platformtheme kde"
        "$mainMod, B, exec, ${pkgs.firefox}/bin/firefox"
        "$mainMod, V, togglespecialworkspace, discord"
        "$mainMod, V, movetoworkspace, special:discord,class:(discord)$"
      ]
    ];

    # Mouse movement binds
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
  };
}
