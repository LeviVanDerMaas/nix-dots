{ pkgs, config, lib, fns,  ... }:

let
  cfg = config.modules.sddm;
  purple = "#701bbb";

  astronautThemePkg = pkgs.sddm-astronaut.override {
    themeConfig = {
      # These config options are custom to this theme
      Background = "${fns.rootRel /assets/wallpapers/tunnel.png}";

      FullBlur = "false";
      PartialBlur = "true";
      FormPosition = "left";
      HideVirtualKeyboard = "true";
      HideLoginButton = "true";
      PasswordFocus = "true";

      HighlightBorderColor = purple;
      HighlightBackgroundColor = purple;
      DropdownSelectedBackgroundColor = purple;
      HoverUserIconColor = purple;
      HoverPasswordIconColor = purple;
      HoverSystemButtonsIconsColor = purple;
      HoverSessionButtonTextColor = purple;
      HoverVirtualKeyboardButtonTextColor = purple;
      WarningColor = purple;
    };
  };
in
{
  options.modules.sddm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };


  config = lib.mkIf cfg.enable {

    # Configure monitor layout with xrandr
    services.xserver.displayManager.setupCommands = config.modules.monitors.xrandrSetupCommand;

    services.displayManager.sddm = {
      enable = true;
      # Default SDDM package is qt5 based, this packages has qt6 based SDDM.
      # Force cuz some DE modules will also try to set this and conflict even if packages match.
      package = lib.mkForce pkgs.kdePackages.sddm;

      # Preview with `sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/<theme-name>/`
      # NOTE: For cursors, easiest way to set one is to use xdg.icons.fallbackCursorThemes, however, if you desire
      # to set it independently you must wrap SDDM to start with env var XCURSOR_PATH containing a path to where the
      # desired cursor theme is located, then set services.displaymanaer.sdd.settings.Themes.CursorTheme to the cursor theme name.
      theme = "sddm-astronaut-theme"; # This theme requires qt6.

      # NOTE: (on 2025-10-10), does not actually add the packages to sddm's environment, only to buildInputs.
      extraPackages = [
        # Astronaut has some propagtedBuildInputs that sddm needs for the theme to function correctly
        astronautThemePkg
      ];
    };

    environment.systemPackages = with pkgs; [
      astronautThemePkg
    ];
  };
}
