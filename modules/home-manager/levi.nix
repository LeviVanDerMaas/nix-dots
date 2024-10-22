{pkgs, lib, config, ...}:

let
  cfg = config.levi;
in
{
  imports = [
    ./bat
    ./git
    ./hyprland
    ./kitty
    ./nvim
    ./shell
    ./fd
  ];

  options = {
    levi.extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages for `home.packages`.";
    };
  };

  config = { 

    # Non-module programs and packages
    programs.firefox.enable = true;
    programs.ripgrep.enable = true;
    programs.zoxide.enable = true;
    home.packages = with pkgs; [
      discord
      fastfetch
      obsidian
      vlc
    ] ++ cfg.extraPackages;

    # Additional Git settings
    programs.git.userName = "Levi van der Maas";
  };
}
