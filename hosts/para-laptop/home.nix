{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  home = {
    username = "levi";
    homeDirectory = "/home/levi";
  };

  imports = [ 
    ../../modules/home-manager/levi
  ];

  modules.home-manager.levi.extraPackages = with pkgs; [
  ];





  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # note that this is an unstable version

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };
}
