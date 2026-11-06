{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  services.hyprpolkitagent.enable = true;
  modules.services.conditonSystemdServiceOnDE = { hyprpolkitagent = "Hyprland"; };
}
