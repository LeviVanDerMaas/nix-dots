{ pkgs, config, lib, ... }:

let
  cfg = config.modules.nixos.sddm;

  # Note to future me: this theme actually has a lot of config support to allow you
  # to do things like play videos for the background as well, so if you ever want to
  # snazz things up you should first check if this already supports it instead of
  # picking a different theme altogether.
  themePkg = pkgs.sddm-astronaut.override {
    themeConfig = {
      # If this doesn't work decaptilazing `Background` may.
      Background = "${../../../assets/wallpapers/woodrot.png}";

      FullBlur = "false";
      PartialBlur = "false";
      HideVirtualKeyboard="true";
      HideLoginButton="true";

      HighlightBorderColor="#CF0700";
      HighlightBackgroundColor="#CF0700";
      DropdownSelectedBackgroundColor="#CF0700";
      HoverUserIconColor="#CF0700";
      HoverPasswordIconColor="#CF0700";
      HoverSystemButtonsIconsColor="#CF0700";
      HoverSessionButtonTextColor="#CF0700";
      HoverVirtualKeyboardButtonTextColor="#CF0700";
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
