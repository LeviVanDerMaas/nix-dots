{
  programs.kitty = {
    enable = true;

    # font.name = "FiraCode Nerd Font";

    settings = {
      background_opacity = "0.80";
      enable_audio_bell = false;
      background_blur = 1;
    };

    keybindings = {
      "ctrl+shift+space" = "launch --cwd=current --type=tab"; # New tab in same dir
      "ctrl+shift+d" = "launch --cwd=current"; # New window in same dir
      "ctrl+shift+n" = "new_os_window_with_cwd"; #New OS window in same dir
    };
  };
}

