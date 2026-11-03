{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    -- Does about 75% in the first 1/10th of the time, easing out the last 25% in the rest.
    hl.curve("easeOut", { type = "bezier", points = { {0.05, 1}, {0.1, 1} } })
    -- Like above, but adds a small overshoot (a "bob") at the end.
    hl.curve("easeOutBob", { type = "bezier", points = { {0.05, 1}, {0.1, 1.05} } })
    -- Does 75% in the first 2/10th of the time. Better than easeOut for very fast transitions.
    hl.curve("easierOut", { type = "bezier", points = { {0.05, 1}, {0.5, 1} } })
    -- Start the transition at approximately 0.87 progress and then eases out immedieatly till 1.
    -- Makes very fast transition over long distances look very snappy, but the trick is noticeable
    -- when multiple things are moving in *different* directions at once.
    hl.curve("87easeOut", { type = "bezier", points = { {-0.5, 1}, {0.20, 1} } })

    -- NOTE: For animations that allow "fade" as a style, the fade is not controlled by
    -- that animation's speed and curve but rather by the fade-subtree, EXCEPT for workspaces(???).
    -- NOTE: Closing animations for windows will not work unless a fade animation is set,
    -- otherwise the window will just instantly disappear (intended behavior, but undocumented
    -- on the wiki). Might be fixed later https://github.com/hyprwm/Hyprland/issues/10352

    -- Base fade for all but workspaces
    hl.animation {
      leaf = "fade",
      bezier = "easeOut",
      speed = 6,
      enabled = true
    }

    -- Workspace animations
    hl.animation {
      leaf = "workspacesIn",
      bezier = "easierOut",
      style = "slide 13%",
      speed = 4,
      enabled = true
    }
    hl.animation {
      leaf = "workspacesOut",
      bezier = "87easeOut",
      style = "slide",
      speed = 3,
      enabled = true
    }
    hl.animation {
      leaf = "specialWorkspace",
      bezier = "easeOut",
      style = "slidefadevert 20%",
      speed = 3,
      enabled = true
    }


    -- Layer animations
    hl.animation {
      leaf = "layers",
      bezier = "easeOut",
      style = "fade",
      speed = 3,
      enabled = true
    }


    -- Window animations
    hl.animation {
      leaf = "windowsIn",
      bezier = "easeOutBob",
      style = "popin",
      speed = 3,
      enabled = true
    }
    hl.animation {
      leaf = "windowsMove",
      bezier = "easeOutBob",
      style = "popin",
      speed = 3,
      enabled = true
    }
    hl.animation {
      leaf = "windowsOut",
      bezier = "easeOut",
      style = "popin 50%",
      speed = 6,
      enabled = true
    }
    hl.animation {
      leaf = "border",
      bezier = "easeOut",
      speed = 3,
      enabled = true
    }
  '';
}
