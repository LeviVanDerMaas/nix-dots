{ inputs, pkgs, ...}:

let
  openrgbServiceDelay = 3;
  openrgbInitSetDelay = 30;
  openrgbInitSetArgs =
    # Run openrgb -h for more info
    "-d 1 -c 5D0167";
in
{
  services.hardware.openrgb = {
    enable = true; # Preconfigures required system settings
    
    # Replace package with one from input, as current nixpkgs
    # version does not support my fans.
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

  # Make the openrgb service wait some time after boot, because apparently
  # the NZXT fans (or perhaps the controller) takes some time to ready:
  # if this service start is not delayed the NZXT fans will almost never be detected
  # until this service is manually restarted.
  systemd.services.openrgb.preStart = "${pkgs.coreutils}/bin/sleep ${builtins.toString openrgbServiceDelay}";

  # A custom systemd service to automatically run openrgb on startup with
  # given arguments (e.g. setting the values of fans that do not retain them
  # between power cycles). Through wantedBy and after, it is set to start
  # after the openrgb service has started. It still may need a delay after that,
  # because the openrgb service runs a server that needs some time to configure itself.
  # This means that once systemd begins starting other services after boot, it will take 
  # at least the delay of this service and openrgb.service until this service actually
  # runs the openrgb arguments.
  systemd.services.openrgbInitSet = {
    enable = true;
    wantedBy = [ "openrgb.service" ];
    after = [ "openrgb.service" ];
    preStart = "${pkgs.coreutils}/bin/sleep ${builtins.toString openrgbInitSetDelay}";
    serviceConfig = {
       Type = "oneshot";
       ExecStart = "${pkgs.openrgb}/bin/openrgb ${openrgbInitSetArgs}";
   };
  };
}
