{ pkgs, config, lib, ... }:

let
  cfg = config.modules.nixos.sddm;
in
{
  options.modules.nixos.sddm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    setupCommands = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Will be passed to `services.xserver.displayManager.setupCommands`.
        These are commands executed just after the X server has started and
        can for example be used to set the monitor layout.
      '';
    };
      
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      theme = "sddm-astronaut-theme";
    };

    environment.systemPackages = with pkgs; [
      (sddm-astronaut.override {
        themeConfig = {
          background = "${../../../assets/wallpapers/woodrot.png}";
          FullBlur = "false";
          PartialBlur = "false";
          OverrideTextFieldColor="#FFFFFF";
          AccentColor="#CF0700";
        };
      })
    ];

    services.xserver.displayManager.setupCommands = cfg.setupCommands;
  };
}
