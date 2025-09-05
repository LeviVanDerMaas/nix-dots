# TODO: look into adding an option to add a file ~/.steam/steam/steam_dev.cfg
# with 'unShaderBackgroundProcessingThreads x' in it (no quotes), where x is a
# number we specify. By default Steam's shader precaching uses only 1 core, this
# having this file with this line makes it use x cores instead (regardless of whether
# backgroundprocessing is turned on or off).

{ pkgs, lib, config, ... }:

let
  cfg = config.modules.gaming.steam;
in
{
  options.modules.gaming.steam = {
    enable = lib.mkEnableOption ''
      Install Steam and configure and install things needed to run games and Proton.
    '';
    install-gperftools = lib.mkEnableOption ''
      Make gperftools available to Steam. Team Fortress 2 depends on this for some reason.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
        extraLibraries = pkgs: with pkgs;
          lib.optionals cfg.install-gperftools [ gperftools ] ++ [
        ];
      };
    };
  };
}
