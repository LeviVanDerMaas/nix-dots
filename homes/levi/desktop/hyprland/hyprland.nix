{ config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland home-manager module. Make sure to also enable system module for Hyprland!
    '';
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";

      extraConfig = /* lua */ ''
        -- Special NixOS var makes most Electron and CEF apps use wayland by default.
        hl.env("NIXOS_OZONE_WL", "1")
      '';
    };
  };
}
