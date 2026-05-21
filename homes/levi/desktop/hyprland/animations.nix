{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
in
lib.mkIf cfg.enable {
  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    -- Does about 75% in the first 1/10th of the time, easing out the last 25% in the rest.
    hl.curve("easeOut", { type = "bezier", points = { {0.05, 1}, {0.1, 1} } })
    hl.curve("easeOutBob", { type = "bezier", points = { {0.05, 1}, {0.1, 1.05} } })

    -- Transition starts at approx 0.87 at slope of about 35 degrees (eyeballed), curve
    -- then gradually flattens out till it reaches 1. Has the effect of making very fast
    -- transition times over larger distances still look smooth while maintaining
    -- snappyness, but the skipping of most of the transition becomes noticeable when
    -- there are more than two moving components with this transition at once.
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
      leaf = "workspaces",
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
