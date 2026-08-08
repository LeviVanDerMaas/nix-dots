{ pkgs, config, lib, fns,  ... }:

let
  cfg = config.modules.sddm;
  purple = "#701bbb";

  astronautThemePkg = pkgs.sddm-astronaut.override {
    themeConfig = {
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
    # Set up monitor layout for SDDM
    services.xserver.displayManager.setupCommands = config.modules.monitors.xrandrSetupCommand;

    services.displayManager.sddm = {
      enable = true;

      # Set theme.
      # Preview with `sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/<theme-name>/`
      # NOTE: For cursors, easiest way to set one is to use xdg.icons.fallbackCursorThemes. If you desire to set it
      # independently, make the cursor available to sddm and set `services.displaymanaer.sdd.settings.Themes.CursorTheme`.
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
