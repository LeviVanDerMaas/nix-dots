{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption ''
      Hyprland system module. Enabling this module will also set up some things
      on the system-side which we can use on the Home-Manager side to add DE
      features to Hyprland. 
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    xdg.portal = {
      enable = true;

      # Hyprland has its own portal that is installed by default via the module.
      # However that portal lacks various interfaces (most notably a file picker)
      # and Hyprland by default recommends falling back to the gtk portal.
      # The gtk portal is DE-agnostic.
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      config.hyprland = { # Portal spec enforces lower-case config names.
        default = "hyprland;gtk";
      };
    };

    # Needed to let udiskie automount when installed on home-manager side.
    modules.udisks2.enable = true;
  };
}
