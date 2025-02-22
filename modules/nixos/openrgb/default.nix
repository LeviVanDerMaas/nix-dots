{ inputs, pkgs, lib, config, ...}:

let
  cfg = config.modules.nixos.openrgb;
  toStr = builtins.toString;
  openrgbInitRun = import ./initRunScript.nix { inherit pkgs; inherit config; };
in
{
  options.modules.nixos.openrgb = {
    enable = 
      lib.mkEnableOption "OpenRGB module";
    serverStartDelay = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = ''
        By how many seconds to delay the OpenRGB server daemon on start.
        Can be useful when some hardware takes (unusually long) to ready
        when booting, meaning the server will not detect them.
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
      default = 0;
      description = ''
        By how many seconds to delay the oneshot service created by the 'initRunArgs'
        option on start. Can for example be used to give the server enough time
        to completely set up.
    '';
    };
    initRunTries = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = ''
        How often to try to execute the oneshot service set-up by 'initRunArgs'
        to complete with exit code 0. Can for example be useful if the OpenRGB server daemon
        might not have detected all hardware yet.
    '';
    };
    initRunTryInterval = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = ''
          Time to wait in seconds before reattempting to run the arguments provided in
          'initRunArgs' if they failed on a previous try (and there are still tries remaining).
    '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true; # Preconfigures required system settings
      
      # Compiles newer (experimental) version because that supports a bunch more hardware that
      # I have.
      package = (pkgs.openrgb.overrideAttrs (oldAttrs: {
        src = inputs.openrgb;
        postPatch = ''
          patchShebangs scripts/build-udev-rules.sh
          substituteInPlace scripts/build-udev-rules.sh \
            --replace /bin/chmod "${pkgs.coreutils}/bin/chmod" \
            --replace /usr/bin/env "${pkgs.coreutils}/bin/env"
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
    systemd.services.openrgbInitSet = lib.mkIf (cfg.initRunArgs != "") {
      enable = true;
      description =  "Custom OpenRGB initial argument runner";
      wantedBy = [ "openrgb.service" ];
      after = [ "openrgb.service" ];
      preStart = "${pkgs.coreutils}/bin/sleep ${toStr cfg.initRunDelay}";
      serviceConfig = {
         Type = "oneshot";
         ExecStart = openrgbInitRun;
      };
    };
  };
}
