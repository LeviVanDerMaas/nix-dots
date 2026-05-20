{ config, ... }:

{
  programs.firefox = {
    enable = true;
    # Explicitly set config path to modern default because our home.stateVersion uses legacy.
    configPath = "${config.xdg.configHome}/mozilla/firefox";
  };
}
