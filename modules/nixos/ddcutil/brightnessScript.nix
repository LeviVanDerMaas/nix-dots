{ pkgs, config, ... }:
let
  cfg = config.modules.nixos.ddcutil;
  toStr = builtins.toString;
  ddcutil = "${pkgs.ddcutil}/bin/ddcutil";
in
pkgs.writeShellScript "ddcutilBrightnessScript" ''
  if [ $# -eq 1 ]; then
    for i in {1..${toStr cfg.numMonitors}}; do
      ${ddcutil} -d $i setvcp x10 $1;
    done
  elif [ $# -eq 2 ]; then
    ${ddcutil} -d $1 setvcp x10 $2;
  else
    echo "Use either <screen> <brightness> or <brightness>"
  fi
''
