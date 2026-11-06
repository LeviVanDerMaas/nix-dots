{ config, lib, osConfig ? {}, ... }:

let 
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.modules.hyprland.enable or false;
      description = ''
        Hyprland home-manager module. Make sure to also enable system module for Hyprland!
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";

      extraConfig = /* lua */ ''
        -- Special NixOS var that makes most Electron and CEF apps use Wayland Native (rather than Xwayland) by default.
        -- It seems like it is slowly being phased out as starting from Electron 38 the default is Wayland native;
        -- since NixOS 25.05 most Electron apps are als on at least 38. Nontheless, it is still actively used
        -- in nixpkgs so we keep it for the forseeable future.
        hl.env("NIXOS_OZONE_WL", "1")
      '';
    };
  };
}
