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
      # Default uses qt5 version, this package makes it use qt6 version.
      # When installing other desktop environments, they may also try to set this option and
      # cause conflicts even when packages match, so we force this option. This should not be
      # a problem usually, but if installing another DE does cause issues in SDDM this may be
      # the cause.
      package = lib.mkForce pkgs.kdePackages.sddm; 

      theme = "sddm-astronaut-theme"; # This theme requires qt6.
      extraPackages = with pkgs; [
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
