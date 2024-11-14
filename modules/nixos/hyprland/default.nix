{ pkgs, lib, config, ... }:

let
  cfg = config.modules.nixos.hyprland;
in
{
  options.modules.nixos.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland system module. Use Home-Mamanger module for configuration.
    '';
    installGTKPortal = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enables and makes available integration with the xdg-desktop-portal-gtk.
        Hyprland implements its own portal but uses this one as fallback by default.
        Notably, Hyprland's portal does not implement a file picker, and since Hyprland
        is still in active early development it is not unlikely something may break at
        some point, so having this as a fallback is useful.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    # Hyprland has its own desktop portal that comes preinstalled with the
    # nix module, however it will use the gtk portal by default as fallback
    # when it cannot perform a certain task (most notably, Hyprlands portal
    # does not implement a file picker).
    xdg.portal.enable = cfg.installGTKPortal;
    xdg.portal.extraPortals = 
      lib.optionals cfg.installGTKPortal [ pkgs.xdg-desktop-portal-gtk ];
  };
}
