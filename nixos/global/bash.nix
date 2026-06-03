{ pkgs, lib, ... }:

{
  # Symlink bash to /bin/bash because some scripts use bad practices and rely
  # on that. This works like how NixOS links /bin/sh
  system.activationScripts.binbash = {
    deps = [ "stdio" ];
    text = ''
      mkdir -p /bin
      ln -sfn ${lib.getExe pkgs.bash} /bin/bash
    '';
  };
}
