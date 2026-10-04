{ lib, fns, config, ... }:

let
  cfg = config.modules.users.levi;
in
{
  options.modules.users.levi = {
    enable = lib.mkEnableOption "Set up levi as user";
  };

  config = lib.mkIf cfg.enable {
    users.users.levi = {
      isNormalUser = true;
      description = "Levi";
      extraGroups = [ "networkmanager" "wheel" "i2c" ];
    };

    home-manager.users.levi.imports = [ (fns.rootRel "homes/levi") ];
  };
}
