{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hyprland.integrations.gaming;
  initialLauncherClasses = [ "steam" ".*prismlauncher.*" ];
  initialGameClasses = [ "steam_app_.*" "gamescope" ".*Minecraft.*" ];
in
{
  options.modules.hyprland.integrations.gaming = {
    enable = lib.mkEnableOption ''
      Dedicate a workspace to gaming. That is, games and launchers will open
      on this workspace; games do so silently.
    '';
    gamingWorkspace = lib.mkOption {
      type = lib.types.either lib.types.int lib.types.str;
      default = 5;
      description = "Which workspace to designate as the gaming workspace";
    };
  };

  # config = lib.mkIf cfg.enable {
  #   wayland.windowManager.hyprland.extraConfig =
  #     let
  #       discordAutoStart = lib.optionalString cfg.autoStart /* lua */ ''
  #         hl.on("hyprland.start", function ()
  #           hl.exec_cmd("discord")
  #         end)
  #       '';
  #     in
  #     /* lua */ ''
  #       hl.workspace_rule { workspace = "special:discord", on_created_empty = "discord" }
  #       hl.window_rule { match = { class = "discord" }, workspace = "special:discord silent"}
  #
  #       hl.bind("SUPER + V", WS.toggle_special("discord"))
  #       hl.bind("SUPER + V", WIN.move({ window = "class:discord", workspace = "special:discord"}))
  #
  #       ${discordAutoStart}
  #     '';
  #
  #   wayland.windowManager.hyprland.settings = {
  #     windowrule = map (ic: "match:initial_class ${ic}, workspace ${toString cfg.gamingWorkspace}") initialLauncherClasses
  #       ++ map (ic: "match:initial_class ${ic}, workspace ${toString cfg.gamingWorkspace} silent") initialGameClasses;
  #   };
  # };
}
