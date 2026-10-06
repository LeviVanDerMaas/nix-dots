{ pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;

    # Wrap kitty to launch all as single instance
    package = pkgs.fns.wrapPkgExe {
      package = pkgs.kitty;
      makeWrapperArgs = [
        "--add-flag" "-1"
      ];
    };

    themeFile = "Catppuccin-Mocha";

    settings = {
      remember_window_size = false;
      confirm_os_window_close = 0;
      background_blur = 1;
      background_opacity = "0.80";
      enable_audio_bell = false;

      # Reorders the default layouts and removes "stack" from the enabled ones.
      # We willl use "stack" with toggle_layout instead
      enabled_layouts = "tall,fat,vertical,horizontal,grid,splits,stack";
    };

    keybindings = {
      # Utility
      "ctrl+shift+g" = "show_last_command_output";
      "ctrl+alt+g" = "show_scrollback";
      "ctrl+alt+c" = "copy_last_command_output";
      "ctrl+alt+v" = "combine | copy_last_command_output | paste_from_clipboard";
      "shift+alt+c" = "copy_ansi_to_clipboard";

      # SCROLLING
      # Lines
      "ctrl+shift+j" = "scroll_line_down";
      "ctrl+shift+k" = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+up" = "scroll_line_up";
      # Pages
      "ctrl+shift+u" = "scroll_page_up";
      "ctrl+shift+d" = "scroll_page_down";
      # Prompts
      "ctrl+alt+u" = "scroll_to_prompt -1";
      "ctrl+alt+d" = "scroll_to_prompt 1";

      # TABS
      # Opening/closing tabs
      "ctrl+shift+space" = "new_tab_with_cwd";
      "ctrl+alt+space" = "detach_tab ask";
      "ctrl+shift+q" = "close_tab";
      # Focussing tabs
      "ctrl+shift+l" = "next_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+h" = "previous_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+1" = "goto_tab 1";
      "ctrl+shift+2" = "goto_tab 2";
      "ctrl+shift+3" = "goto_tab 3";
      "ctrl+shift+4" = "goto_tab 4";
      "ctrl+shift+5" = "goto_tab 5";
      "ctrl+shift+6" = "goto_tab 6";
      "ctrl+shift+7" = "goto_tab 7";
      "ctrl+shift+8" = "goto_tab 8";
      "ctrl+shift+9" = "goto_tab 9";
      "ctrl+shift+0" = "goto_tab 10";
      # Moving tabs
      "ctrl+shift+," = "move_tab_backward";
      "ctrl+shift+." = "move_tab_forward";

      # WINDOWS
      # Opening/closing windows
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+alt+enter" = "detach_window ask";
      "ctrl+shift+n" = "new_os_window_with_cwd";
      # Focussing windows
      "ctrl+alt+h" = "neighboring_window left";
      "ctrl+alt+j" = "neighboring_window bottom";
      "ctrl+alt+k" = "neighboring_window top";
      "ctrl+alt+l" = "neighboring_window right";
      "ctrl+alt+left" = "neighboring_window left";
      "ctrl+alt+down" = "neighboring_window bottom";
      "ctrl+alt+up" = "neighboring_window top";
      "ctrl+alt+right" = "neighboring_window right";
      "ctrl+alt+1" = "nth_window 0";
      "ctrl+alt+2" = "nth_window 1";
      "ctrl+alt+3" = "nth_window 2";
      "ctrl+alt+4" = "nth_window 3";
      "ctrl+alt+5" = "nth_window 4";
      "ctrl+alt+6" = "nth_window 5";
      "ctrl+alt+7" = "nth_window 6";
      "ctrl+alt+8" = "nth_window 7";
      "ctrl+alt+9" = "nth_window 8";
      "ctrl+alt+0" = "nth_window 9";
      # Moving windows
      "shift+alt+h" = "move_window left";
      "shift+alt+j" = "move_window bottom";
      "shift+alt+k" = "move_window top";
      "shift+alt+l" = "move_window right";
      "shift+alt+left" = "move_window left";
      "shift+alt+down" = "move_window bottom";
      "shift+alt+up" = "move_window top";
      "shift+alt+right" = "move_window right";
      "shift+alt+1" = "swap_with_window 0";
      "shift+alt+2" = "swap_with_window 1";
      "shift+alt+3" = "swap_with_window 2";
      "shift+alt+4" = "swap_with_window 3";
      "shift+alt+5" = "swap_with_window 4";
      "shift+alt+6" = "swap_with_window 5";
      "shift+alt+7" = "swap_with_window 6";
      "shift+alt+8" = "swap_with_window 7";
      "shift+alt+9" = "swap_with_window 8";
      "shift+alt+0" = "swap_with_window 9";
      # Layout management
      "ctrl+shift+p" = "next_layout";
      "ctrl+alt+f" = "toggle_layout stack";
    };
  };

  modules.kdeConfig.kdeglobals = {
    General = {
      TerminalApplication = "kitty";
    };
  };
}

