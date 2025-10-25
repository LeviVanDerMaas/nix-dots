{ flake-inputs, pkgs, lib, config, ...}:

let
  cfg = config.modules.openrgb;
  toStr = builtins.toString;
in
{
  options.modules.openrgb = {
    enable = 
      lib.mkEnableOption "OpenRGB module";
    serverStartDelay = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = ''
        By how many seconds to delay the OpenRGB server daemon on start.
        Can be useful when some hardware takes (unusually long) to ready
        when booting: if the OpenRGB server starts while hardware is not ready
        it seems that the server will never detect that hardware for the duration
        of its run, so this can prevent that.
    '';
    };
    initRunArgs = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        If set, this will create an additional systemd oneshot service
        'openrgbInitRun' to execute after the OpenRGB server daemon has started
        that will execute 'openrgb' with the arguments given in this string.
        See 'openrgb -h' for more info.
    '';
    };
    initRunDelay = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = ''
        Time to wait in seconds before attempting to run the arguments
        provided in 'initRunArgs'. This delay is applied on each try. This is
        useful since it might take a while after a system boot before all
        hardware is actually fully known to the OpenRGB server (not sure if
        that has to do with OpenRGB implementation or the hardware itself).
    '';
    };
    initRunTries = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = ''
        How often to try to execute the oneshot service set-up by 'initRunArgs'
        to complete with exit code 0.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true; # Preconfigures required system settings
      
      # Compiles newer (experimental) version because that supports a bunch more hardware that
      # I have.
      package = (pkgs.openrgb.overrideAttrs (oldAttrs: {
        src = flake-inputs.openrgb;
        patches = [
          # Sometime after nixpkgS 25.05, a patch was added here. Not sure what it's for but
          # it adds an extra import to the file qt/OpenRGBFonts.cpp, but in the version
          # of openrgb we pull that's already included so now it conflicts, but it should
          # be fine to just remove this patch from nixpkgs. I'm not even sure what the patch
          # is for considering the version of openrgb in nixpkgs is still 0.9, which does not
          # include this import in the original source code?
        ];
        postPatch = ''
          patchShebangs scripts/build-udev-rules.sh
          substituteInPlace scripts/build-udev-rules.sh \
            --replace-warn /bin/chmod "${pkgs.coreutils}/bin/chmod" \
            --replace-warn /usr/bin/env "${pkgs.coreutils}/bin/env"
        '';
      }));
    };

    systemd.services.openrgb.preStart = "${pkgs.coreutils}/bin/sleep ${toStr cfg.serverStartDelay}";

    # A custom systemd service to automatically run openrgb on startup with
    # given arguments (e.g. setting the values of fans that do not retain them
    # between power cycles). Through wantedBy and after, it is set to start
    # after the openrgb service has started. It still may need a delay after that,
    # because the openrgb service runs a server that needs some time to configure itself.
    # This means that once systemd begins starting other services after boot, it will take 
    # at least the delay of this service and openrgb.service until this service actually
    # runs the openrgb arguments.
    systemd.services.openrgbInitRun = lib.mkIf (cfg.initRunArgs != "") {
      enable = true;
      description =  "Custom OpenRGB initial argument runner";
      wantedBy = [ "openrgb.service" ];
      after = [ "openrgb.service" ];
      preStart = "${pkgs.coreutils}/bin/sleep ${toStr cfg.initRunDelay}";
      startLimitBurst = cfg.initRunTries;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.openrgb}/bin/openrgb ${cfg.initRunArgs}";
        Restart = "on-failure";
        StartLimitIntervalSec = "infinity";
        # RestartSec = cfg.initRunTryInterval; # same as preStart def above, but has no initial delay.
      };
    };
  };
}
