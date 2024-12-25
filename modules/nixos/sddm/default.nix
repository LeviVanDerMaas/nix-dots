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
    services.xserver.displayManager.setupCommands = cfg.setupCommands;
    
    services.displayManager.sddm = {
      enable = true;
      # Default SDDM package is qt5 based, this packages has qt6 based SDDM.
      # When installing other desktop environments, they may also try to set this option and
      # cause conflicts even when packages match, so we force this option.
      package = lib.mkForce pkgs.kdePackages.sddm; 

      theme = "sddm-astronaut-theme"; # This theme requires qt6.
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
  };
}
