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
      Install gperftools. Team Fortress 2 depends on this for some reason.
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
