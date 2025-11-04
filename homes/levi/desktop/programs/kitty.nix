{
  programs.kitty = {
    enable = true;
    
    themeFile = "Catppuccin-Mocha";

    settings = {
      confirm_os_window_close = 0;
      background_blur = 1;
      background_opacity = "0.80";
      enable_audio_bell = false;
    };

    keybindings = {
      "ctrl+shift+space" = "launch --cwd=current --type=tab"; # New tab in same dir
      "ctrl+shift+d" = "launch --cwd=current"; # New window in same dir
      "ctrl+shift+n" = "new_os_window_with_cwd"; #New OS window in same dir
    };
  };

  modules.kdeConfig.kdeglobals = {
    General = {
      TerminalApplication = "kitty";
    };
  };
}

