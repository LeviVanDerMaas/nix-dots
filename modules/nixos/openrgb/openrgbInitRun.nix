{ pkgs, config, ... }:

let
  cfg = config.openrgb;
  toStr = builtins.toString;
in
pkgs.writeShellScript "openrgbInitRun" ''
  for i in {1..${builtins.toString (cfg.initRunTries - 1)}}; do
    ${pkgs.openrgb}/bin/openrgb ${cfg.initRunArgs}
    if [ $? -eq 0 ]; then
        return $?
    fi
    ${pkgs.coreutils}/bin/sleep ${toStr cfg.initRunTryInterval}
  done
'' 
