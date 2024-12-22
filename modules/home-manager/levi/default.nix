{pkgs, lib, config, ...}:

let
  cfg = config.modules.home-manager.levi;
in
{
  imports = [
    ./bat
    ./dunst
    ./fd
    ./firefox
    ./git
    ./hyprland
    ./kitty
    ./nvim
    ./ripgrep
    ./shell
    ./thefuck
    ./theme
    ./waybar
    ./zoxide
  ];

  options.modules.home-manager.levi = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = ''
        Extra packages for `home.packages`.
        Intent is that this allows adding packages to home-manager externally.
        This, for example, allows installing packages at home-level on a per-system basis.
      '';
    };
  };

  config = { 
    # Non-module programs and packages
    home.packages = with pkgs; [
      discord
      kdePackages.dolphin
      fastfetch
      obsidian
      vlc
    ] ++ cfg.extraPackages;
  };
}
