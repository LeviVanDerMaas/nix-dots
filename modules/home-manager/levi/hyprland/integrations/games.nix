{ config, lib, ... }:

let
  cfg = config.modules.home-manager.levi.hyprland.integrations.games;
  initialGameClasses = [
    "steam" # Remove this if that bug with special workspaces is ever fixed.
    "steam_app_.*"
    "gamescope"
    ".*prismlauncher.*"
    ".*Minecraft.*"
  ];
in
{
  options.modules.home-manager.levi.hyprland.integrations.games = {
    enable = lib.mkEnableOption ''
      Set up a workspace on which games go by default. 
      Also I commented out some stuff that would assign steam to its own workspace,
      the problem is that there is a bug with either steam or Hyprland that causes
      certain xwayland sub-windows in steam to spawn on the focussed workspace instead
      of the open special workspace; right now this basically just opens everything specified
      in workspace 5.
    '';
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # workspace = [
      #   "special:steam, on-created-empty:steam"
      # ];

      windowrulev2 = [
        # "workspace special:steam silent, initialClass:(steam)"
      ] ++ builtins.map (c: "workspace 5 silent, initialClass:(${c})") initialGameClasses;

      # bind = [
      #   "$mainMod, G, togglespecialworkspace, steam"
      #   "$mainMod, G, movetoworkspace, special:steam,class:(steam)$"
      # ];
    };
  };
}
