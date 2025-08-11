{ flake-inputs, pkgs, ... }:

{
  imports = [ flake-inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./.;
    # extraPackages will be available to gjs runtime
    # hm-module only includes astal3, astal4 and astal-io by default.
    extraPackages = (with flake-inputs.astal.packages.${pkgs.system}; [
      # astal libs
      apps
      battery
      bluetooth
      hyprland
      mpris
      network
      notifd
      tray
      wireplumber
    ]) ++ (with pkgs; [
      # nixpkgs
    ]);
  };
}
