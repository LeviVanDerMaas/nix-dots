{ lib, flake-inputs, config, rootRel, ... }:

let
  cfg = config.common.users.levi;
in
{
  imports = [
    flake-inputs.home-manager.nixosModules.home-manager
  ];

  options.common.users.levi = {
    enable = lib.mkEnableOption "Set up levi as user";

    extraHMConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Extra config added to levi's Home Manager config. Mainly useful
        to allow systems to pass in sytem-specific tweaks to levi's Home Manager
        config. Note this shouldn't be a module, just an attrset for the `config`
        attribute of a Home Manager module.
      '';
    };
  };

  config = {
    users.users.levi = {
      isNormalUser = true;
      description = "Levi";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs = { inherit flake-inputs rootRel; };
      users.levi = { ... }: {
        # Doing it like this lets the extra hm config get merged properly.
        imports = [ (rootRel /homes/levi) ];
        config = cfg.extraHMConfig;
      };
    };
  };
}
