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

      hl.bind("SUPER + GRAVE", DIS.exec_raw("gsr-ui-cli toggle-show"))
      hl.bind("SUPER + F1", DIS.exec_raw("gsr-ui-cli replay-save"))
      hl.bind("SUPER + SHIFT + F1", DIS.exec_raw("gsr-ui-cli toggle-replay"))
      hl.bind("SUPER + F2", DIS.exec_raw("gsr-ui-cli take-screenshot"))
      hl.bind("SUPER + SHIFT + F2", DIS.exec_raw("gsr-ui-cli take-screenshot-region"))
      hl.bind("SUPER + CTRL + F2", DIS.exec_raw("gsr-ui-cli take-screenshot-window"))
      hl.bind("SUPER + F3", DIS.exec_raw("gsr-ui-cli toggle-pause"))
      hl.bind("SUPER + SHIFT + F3", DIS.exec_raw("gsr-ui-cli toggle-record"))
    '';
  };
}
