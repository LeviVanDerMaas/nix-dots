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
      "ctrl+shift+d" = "new_window_with_cwd";
      "ctrl+alt+d" = "detach_window ask";
      "ctrl+shift+space" = "new_tab_with_cwd";
      "ctrl+shift+n" = "new_os_window_with_cwd";
      "ctrl+alt+n" = "detach_tab ask";

    };
  };

  modules.kdeConfig.kdeglobals = {
    General = {
      TerminalApplication = "kitty";
    };
  };
}

