{pkgs, config, lib, ...}:

{
  imports = [
    ./hyprland
    ./kde
    ./neovim
    ./theme
    ./waybar

    ./bash.nix
    ./bat.nix
    ./dunst.nix
    ./fd.nix
    ./firefox.nix
    ./git.nix
    ./kitty.nix
    ./kitty.nix
    ./ripgrep.nix
    ./starship.nix
    ./udiskie.nix
    ./yazi.nix
    ./zoxide.nix
  ];

  config = { 
    programs.home-manager.enable = true;

    home = {
      username = "levi";
      homeDirectory = "/home/levi";

      # Non-module packages
      packages = with pkgs; [
        discord
        fastfetch
        obsidian
        vlc
      ];
    };





    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.05"; # note that this is an unstable version
  };
}
