{ pkgs, lib, config, ... }:

let
  cfg = config.modules.services;
in
{
  options.modules.services = with lib.types; {
    conditonSystemdServiceOnDE = lib.mkOption {
      type = attrsOf (either str (listOf str));
      default = {};
      description = ''
        For each key `k`, modifies `systemd.user.services.k` by adding
        `ConditionEnvironment` values to each service's `[Unit]` section such
        that the service will start only if the environment variable
        `XDG_CURRENT_DESKTOP` is equal to one of the values listed for `k`.
      '';
    };
  };

  config = {
    systemd.user.services =
      let
        genConditionEnvironmentVals = des:
          map (de: "|XDG_CURRENT_DESKTOP=${de}") (lib.toList des);
        mkServiceOptions = u: des:
          { Unit.ConditionEnvironment = genConditionEnvironmentVals des; };
      in
      lib.mapAttrs mkServiceOptions cfg.conditonSystemdServiceOnDE;
  };
}
