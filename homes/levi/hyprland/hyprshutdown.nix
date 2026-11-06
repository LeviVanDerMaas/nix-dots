{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprshutdown;
in
{
  options.modules.hyprshutdown = {
    logoutCommand = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "hyprshutdown -t 'Exiting Hyprland...'";
    };
    shutdownCommand = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "hyprshutdown -t 'Shutting down...' --post-cmd 'poweroff'";
    };
    rebootCommand = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "hyprshutdown -t 'Rebooting...' --post-cmd 'reboot'";
    };
  };
  config = lib.mkIf config.modules.hyprland.enable {
    home.packages = with pkgs; [ hyprshutdown ];
    wayland.windowManager.hyprland.extraConfig = /* lua */ ''
      hl.bind("SUPER + ALT + CTRL + SHIFT + E", DIS.exec_cmd("${cfg.logoutCommand}"))
      hl.bind("SUPER + ALT + CTRL + SHIFT + P", DIS.exec_cmd("${cfg.shutdownCommand}"))
      hl.bind("SUPER + ALT + CTRL + SHIFT + R", DIS.exec_cmd("${cfg.rebootCommand}"))
      hl.bind("SUPER + ALT + CTRL + SHIFT + Z", DIS.exec_cmd("systemctl suspend"))
    '';
  };
}
