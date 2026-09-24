{ lib, config, ... }:

let
  cfg = config.modules.localsend;
in
{
  options.modules.localsend = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.localsend.enable = true;
  };
}
