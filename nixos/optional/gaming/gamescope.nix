{ pkgs, config,  lib, ... }:

let
  cfg = config.modules.gaming.gamescope;
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
  options.modules.gaming.gamescope = {
    enable = lib.mkEnableOption ''Enable custom gamescope module'';
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      package = gamescope-3_16_2;
    };
  };
}
