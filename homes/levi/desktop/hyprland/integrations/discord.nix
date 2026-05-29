{ config, lib, ... }:

let
  cfg = config.modules.hyprland.integrations.discord;
in
{
  options.modules.hyprland.integrations.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.hyprland.enable;
      description = ''
        Integrates Discord by setting up a special workspace for it.
      '';
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Starts Discord alongside Hyprland.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig =
      let
        discordAutoStart = lib.optionalString cfg.autoStart /* lua */ ''
          hl.on("hyprland.start", function ()
            hl.exec_cmd("discord")
          end)
        '';
      in
      /* lua */ ''
        hl.workspace_rule { workspace = "special:discord", on_created_empty = "discord" }
        hl.window_rule {
            match = { class = "discord" },
            workspace = "special:discord silent",
            tag = "suppressInitialActivate"
        }

        hl.bind("SUPER + V", WS.toggle_special("discord"))
        hl.bind("SUPER + V", WIN.move({ window = "class:discord", workspace = "special:discord"}))

        ${discordAutoStart}
      '';
  };
}
