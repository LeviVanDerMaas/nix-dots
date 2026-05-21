{ config, lib, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  imports = [
    # Global values and functions for lua config
    ./luaglobals.nix

    # Hyprland configuration
    ./animations.nix
    ./binds.nix
    ./config.nix
    ./monitors.nix
    ./windowrules.nix
    # TODO: Reenable this once ported to Lua
    # ./integrations

    # Configuration of hyprland ecosystem tools
    ./hyprland-portals.nix
    ./hyprpaper.nix
    ./hyprpolkitagent.nix
    ./hyprshutdown.nix
    ./hyprtoolkit.nix
  ];

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
