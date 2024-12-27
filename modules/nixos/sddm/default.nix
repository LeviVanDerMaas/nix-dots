{ pkgs, config, lib, ... }:

let
  cfg = config.modules.nixos.sddm;
  themePkg = pkgs.sddm-astronaut.override {
    themeConfig = {
      background = "${../../../assets/wallpapers/woodrot.png}";
      FullBlur = "false";
      PartialBlur = "false";
      OverrideTextFieldColor="#FFFFFF";
      AccentColor="#CF0700";
    };
  };
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
      extraPackages = with pkgs; [
        themePkg
      ];
    };

    environment.systemPackages = with pkgs; [
      # Not sure why, but if the package for theming is not available in BOTH
      # the extraPackages of sddm and the systemPackages, it will fail to apply.
      # It seems to have something to do with specifically the qt6 version of SDDM that we
      # forcefully insert.
      themePkg
    ];
  };
}
