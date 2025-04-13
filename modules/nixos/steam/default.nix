{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.modules.nixos.steam;
  gamescope-3_16_2 = (pkgs.gamescope.overrideAttrs (oldAttrs: {
    version = "3.16.2";
    src = pkgs.fetchFromGitHub {
      owner = "ValveSoftware";
      repo = "gamescope";
      tag = "3.16.2";
      fetchSubmodules = true;
      hash = "sha256-vKl2wYAt051+1IaCGB1ylGa83WTS+neqZwtQ/4MyCck=";
    };
  }));
in
{
  options.modules.nixos.steam = {
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

          gamescope-3_16_2
        ];
        extraLibraries = pkgs: with pkgs;
          lib.optionals cfg.install-gperftools [ gperftools ] ++ [
        ];
      };
    };

    programs.gamescope = {
      enable = true;
      package = gamescope-3_16_2;
    };
  };
}
