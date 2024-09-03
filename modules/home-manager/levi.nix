{pkgs, lib, config, ...}:

let
  cfg = config.levi;
in
{
  imports = [
    ./git
    ./hyprland
    ./kitty
    ./nvim
    ./shell
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
    programs.bat.enable = true;
    programs.firefox.enable = true;
    programs.ripgrep.enable = true;
    programs.zoxide.enable = true;
    home.packages = with pkgs; [
      discord
      obsidian
      prismlauncher
    ] ++ cfg.extraPackages;

    # Additional Git settings
    programs.git.userName = "Levi van der Maas";
  };
}
