{ config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = /* lua */ ''
      hl.window_rule { -- Pavucontrol
        match = { initial_class = "org.pulseaudio.pavucontrol"},
        float = true, center = true
      }
      hl.window_rule { -- nm-connection-editor, a.k.a nm-applet's GUI
        match = { initial_class = "nm-connection-editor"},
        float = true, center = true
      }
    '';
  };
}
