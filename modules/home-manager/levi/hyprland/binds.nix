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

    "${mods}, UP, ${dispatcher}, u"
    "${mods}, LEFT, ${dispatcher}, l"
    "${mods}, DDOWN, ${dispatcher}, d"
    "${mods}, RIGHT, ${dispatcher}, r"

    "${mods}, H, ${dispatcher}, l"
    "${mods}, J, ${dispatcher}, d"
    "${mods}, K, ${dispatcher}, u"
    "${mods}, L, ${dispatcher}, r"
  ];
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    # MOD3 is typically not set to any (physically available) key in most every layout.
    # So you will need a custom layout, e.g. make Super_R trigger MOD3 (instead of MOD4, like Super_L).
    # This has the convenience of being practically guaranteed to never interfere with any other
    # mods in programs or software.
    "$alphaMod" = "SUPER";
    "$betaMod" = "MOD3";
    "$extraMod" = "CTRL";

    bind = builtins.concatLists [
      # Generated general workspace binds
      (genNumWorkspaceBinds "$alphaMod" "focusworkspaceoncurrentmonitor")
      (genNumWorkspaceBinds "$alphaMod $extrayMod" "workspace")
      (genNumWorkspaceBinds "$betaMod" "movetoworkspace")
      (genNumWorkspaceBinds "$betaMod $extraMod" "movetoworkspacesilent")

      # Generated general window binds
      (genDirectionBinds "$alphaMod" "movefocus")
      (genDirectionBinds "$betaMod" "movewindow")
      (genDirectionBinds "$betaMod $extraMod" "swapwindow")

      [ 
        # Other (non-generated) general binds
        "$alphaMod, F, fullscreen"
        "$betaMod, F, togglefloating"
        "$betaMod, P, pin"
        "$betaMod, C, centerwindow"
        
        "$alphaMod $betaMod, C, killactive"
        "$alphaMod $betaMod $extraMod, E, exit"
        "$alphaMod $betaMod $extraMod ALT, P, exec, poweroff"

        # Application binds
        "$alphaMod, T, exec, ${pkgs.kitty}/bin/kitty"
        "$alphaMod, SPACE, exec, ${pkgs.ulauncher}/bin/ulauncher-toggle"
        "$alphaMod, E, exec, ${pkgs.dolphin}/bin/dolphin"
        "$alphaMod, B, exec, ${pkgs.firefox}/bin/firefox"
        "$alphaMod, V, togglespecialworkspace, discord"
        "$alphaMod, V, movetoworkspace, special:discord,class:(discord)$"
         
        # Screenshots
        " , PRINT, exec, grimblast copy output"
        "$alphaMod, PRINT, exec, grimblast copy area"
        "$alphaMod $extraMod, PRINT, exec, grimblast copy screen"
        "$betaMod, PRINT, exec, hyprpicker -anf hex"
      ]
    ];

    # Mouse movement binds
    bindm = [
      "$alphaMod, mouse:272, movewindow"
      "$alphaMod, mouse:273, resizewindow"
    ];
  };
}
