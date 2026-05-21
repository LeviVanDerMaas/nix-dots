{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    hl.config {
      input = {
        kb_layout = "us",
        kb_variant = "altgr-weur", -- https://altgr-weur.eu/
          kb_options = "caps:escape_shifted_capslock",
        repeat_rate = 60,
        repeat_delay = 600,
      },

      general = {
        border_size = 2,
        gaps_in = 5,
        gaps_out = 10,
        ["col.active_border"] = "#701bbbee",
        ["col.inactive_border"] = "#35293dcc",

        layout = "dwindle",
        no_focus_fallback = true,
      },

      decoration = {
        rounding = 3,
        blur = {
          enabled = true,
          size = 3,
        },
      },

      dwindle = {
        preserve_split = true,
        precise_mouse_move = true, -- Smart split but only when using the mouse
      },

      binds = {
        hide_special_on_workspace_change = true,
        scroll_event_delay = 0,
      },

      misc = {
        focus_on_activate = true, -- Let windows request focus; this can also be set per window
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
      },
    }
  '';
}
