{ pkgs, config, lib, rootRel,  ... }:

let
  cfg = config.common.sddm;
  red = "#CF0700";

  # Note to future me: this theme actually has a lot of config support to allow you
  # to do things like play videos for the background as well, so if you ever want to
  # snazz things up you should first check if this already supports it instead of
  # picking a different theme altogether.
  themePkg = pkgs.sddm-astronaut.override {
    themeConfig = {
      # If this doesn't work decaptilazing `Background` may.
      Background = "${rootRel /assets/wallpapers/woodrot.png}";

      FullBlur = "false";
      PartialBlur = "false";
      HideVirtualKeyboard = "true";
      HideLoginButton = "true";

      HighlightBorderColor = red;
      HighlightBackgroundColor = red;
      DropdownSelectedBackgroundColor = red;
      HoverUserIconColor = red;
      HoverPasswordIconColor = red;
      HoverSystemButtonsIconsColor = red;
      HoverSessionButtonTextColor = red;
      HoverVirtualKeyboardButtonTextColor = red;
      WarningColor = red;
    };
  };
in
{
  options.common.sddm = {
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
      # Force cuz some DE modules will also try to set this and conflict even if packages match.
      package = lib.mkForce pkgs.kdePackages.sddm; 

      # Preview with `sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/sddm-astronaut-theme/`
      theme = "sddm-astronaut-theme"; # This theme requires qt6.
      extraPackages = with pkgs; [
        themePkg
      ];
    };

    environment.systemPackages = with pkgs; [
      # If theme is not in both extraPackages and systemPackages it will fail to apply for some reason
      # May have to do with using a qt6 based SDDM package.
      themePkg
    ];
  };
}
