{ pkgs, config, ... }:
let
  cfg = config.modules.nixos.openrgb;
  toStr = builtins.toString;
in
pkgs.writeShellScript "openrgbInitRun" ''
  for i in {1..${toStr (cfg.initRunTries - 1)}}; do
    ${pkgs.openrgb}/bin/openrgb ${cfg.initRunArgs} &> /dev/null
    if [ $? -eq 0 ]; then
        exit $?
    fi
    ${pkgs.coreutils}/bin/sleep ${toStr cfg.initRunTryInterval}
  done
  # If we get here this is the last attempt and we want stderr
  ${pkgs.openrgb}/bin/openrgb ${cfg.initRunArgs} 1> /dev/null
''
