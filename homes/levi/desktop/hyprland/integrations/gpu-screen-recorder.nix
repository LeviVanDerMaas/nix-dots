{ config, lib, ... }:

let
  cfg = config.modules.hyprland.integrations.gpu-screen-recorder;
in
{
  options.modules.hyprland.integrations.gpu-screen-recorder = {
    autostart = lib.mkOption {
      default = config.modules.gpu-screen-recorder.enable &&
        config.modules.hyprland.integrations.gaming.enable;
      type = lib.types.bool;
      description = "Autostart gsr-ui with Hyprland.";
    };
  };

  config = lib.mkIf config.modules.hyprland.enable {
    wayland.windowManager.hyprland.extraConfig = lib.mkIf cfg.autostart /* lua */ ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("gsr-ui")
      end)
    '';
  };
}
