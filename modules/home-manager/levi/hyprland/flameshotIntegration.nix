{ pkgs, config, lib, ... }:

{
  # Set up some window rules to integrate flameshot,
  # which was designed for X11.
  wayland.windowManager.hyprland.settings = {
    # noanim isn't necessary but animations with these rules might look bad. use at your own discretion.
    windowrulev2 = [
      "noanim, class:^(flameshot)$"
      "float, class:^(flameshot)$"
      "move 0 0, class:^(flameshot)$"
      "pin, class:^(flameshot)$"
      # set this to your leftmost monitor id, otherwise you have to move your cursor to the leftmost monitor
      # before executing flameshot
      "monitor 0, class:^(flameshot)$"

      # Makes it work with multiple screens
      "float,title:^(flameshot)"
      "move 0 0,title:^(flameshot)"
      "suppressevent fullscreen,title:^(flameshot)"
    ];

    # # ctrl-c to copy from the flameshot gui gives warped images sometimes, but
    # # setting the env fixes it
    # bind = ..., exec, XDG_CURRENT_DESKTOP=sway flameshot gui
  };
}
