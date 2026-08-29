{ lib, config, ... }:

let
  cfg = config.modules.gpu-screen-recorder;
in
{
  options.modules.gpu-screen-recorder = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Install gpu-screen-recorder to this system. Settings are managed from within the UI.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpu-screen-recorder = {
      enable = true;
      ui.enable = true;
    };
  };
}
