{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  home.packages = with pkgs; [ hyprshutdown ];
  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    hl.bind("SUPER + ALT + CTRL + SHIFT + E", DIS.exec_cmd("hyprshutdown -t 'Exiting Hyprland...'"))
    hl.bind("SUPER + ALT + CTRL + SHIFT + P", DIS.exec_cmd("hyprshutdown -t 'Shutting down...' --post-cmd 'poweroff'"))
    hl.bind("SUPER + ALT + CTRL + SHIFT + R", DIS.exec_cmd("hyprshutdown -t 'Rebooting...' --post-cmd 'reboot'"))
    hl.bind("SUPER + ALT + CTRL + SHIFT + Z", DIS.exec_cmd("systemctl suspend"))
  '';
}
