{ lib, ... }:

{
  config = {
    wayland.windowManager.hyprland.extraConfig = lib.mkAfter /* lua */ ''
      -- Attempt to require "hotconfig" from the same directory as the config.
      -- This is mainly useful on Nix for quickly testing config changes.
      local loaded, err = pcall(require, "hotconf")
      if loaded then
        debug_notify("Hyprland succesfully loaded hotconf.lua!")
      end
    '';
  };
}
