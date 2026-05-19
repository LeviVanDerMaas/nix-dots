{ config, lib, ... }:

let
  cfg = config.modules.hyprland;

  keyDirection = rec {
    UP = "u";    K = UP;    W = UP;
    LEFT = "l";  H = LEFT;  A = LEFT;
    DOWN = "d";  J = DOWN;  S = DOWN;
    RIGHT = "r"; L = RIGHT; D = RIGHT;
  };

  genDigitBinds = genDigitBinds' {};
  genDigitBinds_rAbs = genDigitBinds' { paramPre = "r~"; };
  genDigitBinds' = { paramPre ? "", paramSuf ? "" }: mods: dispatcher:
    let
      digitBind = key: id:
        "${mods}, ${toString key}, ${dispatcher}, ${paramPre}${toString id}${paramSuf}";
      binds1to9 = builtins.genList (d: let d' = d + 1; in digitBind d' d') 9;
      bind0 = digitBind 0 10;
    in
    binds1to9 ++ [ bind0 ];

  genDirectionBinds = genDirectionBinds' {};
  genDirectionBinds' = { paramPre ? "", paramSuf ? ""}: mods: dispatcher:
    let
      directionBind = key: direction:
        "${mods}, ${key}, ${dispatcher}, ${paramPre}${direction}${paramSuf}";
    in
    lib.mapAttrsToList directionBind keyDirection;
in
lib.mkIf cfg.enable {
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$allMods" = "$mainMod ALT SHIFT CTRL";

    "$focusMod" = "SHIFT"; # This mod should move focus on applicable dispatchers
    "$silentMod" = "CTRL"; # This mod shouldn't move focus on applicable dispatchers
    "$monKey" = "GRAVE"; # This key is for non-directinal monitor management.

    bind = lib.flatten [
      # Workspace binds
      (genDigitBinds_rAbs "$mainMod" "workspace")
      (genDigitBinds_rAbs "$mainMod $focusMod" "movetoworkspace")
      (genDigitBinds_rAbs "$mainMod $silentMod" "movetoworkspacesilent")
      "$mainMod, mouse_down, workspace, r-1"
      "$mainMod, mouse_up, workspace, r+1"

      # Monitor binds
      (genDirectionBinds "$mainMod ALT" "focusmonitor")
      (genDirectionBinds' { paramPre = "mon:"; } "$mainMod ALT $focusMod" "movewindow")
      (genDirectionBinds' { paramPre = "mon:"; paramSuf = " silent"; } "$mainMod ALT $silentMod" "movewindow")
      "$mainMod, $monKey, focusmonitor, +1"
      "$mainMod $silentMod, $monKey, movewindow, mon:+1 silent"
      "$mainMod $focusMod, $monKey, movewindow, mon:+1"
      "$mainMod, mouse_left, focusmonitor, l"
      "$mainMod, mouse_right, focusmonitor, r"

      # Window binds
      (genDirectionBinds "$mainMod" "movefocus")
      (genDirectionBinds "$mainMod $focusMod" "movewindow")
      (genDirectionBinds' { paramSuf = " silent"; } "$mainMod $silentMod" "movewindow")
      (genDirectionBinds "$mainMod $focusMod $silentMod" "swapwindow")
      "$mainMod, TAB, cyclenext"
      # Split management
      "$mainMod, PERIOD, layoutmsg, splitratio +0.1"
      "$mainMod, COMMA, layoutmsg, splitratio -0.1"
      "$mainMod, R, layoutmsg, swapsplit"
      "$mainMod SHIFT, R, layoutmsg, togglesplit" # Requires preserve_split to be true
      # Screenstate management
      "$mainMod, F, fullscreen, 0"
      "$mainMod SHIFT, F, fullscreen, 1"
      # Floating management
      "$mainMod, Z, togglefloating"
      "$mainMod SHIFT, Z, centerwindow"
      "$mainMod ALT, Z, pin"
      # Kill binds
      "$mainMod ALT, C, killactive"
      "$allMods, C, forcekillactive"

      # Application binds
      "$mainMod, T, exec, kitty"
      "$mainMod, E, exec, dolphin"
      "$mainMod, B, exec, firefox"
      "$mainMod SHIFT, B, exec, firefox --private-window"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
  };
}
