{ lib, fns, flake-inputs, config, ... }:

let
  cfg = config.modules.users.levi;
in
{
  options.modules.users.levi = {
    enable = lib.mkEnableOption "Set up levi as user";

    extraHMConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Extra defintions to pass to `config` for levi's Home Manager
        configuration. Mainly useful to set system-specific tweaks to the
        HM-config from the system config.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.levi = {
      isNormalUser = true;
      description = "Levi";
      extraGroups = [ "networkmanager" "wheel" "i2c" ];
    };

    home-manager.users.levi = { ... }: {
      imports = [ (fns.rootRel /homes/levi) ];
      config = cfg.extraHMConfig;
    };
  };
}
