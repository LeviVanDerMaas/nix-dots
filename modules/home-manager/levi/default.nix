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
      description = ''
        Extra packages for `home.packages`.
        Intent is that this allows adding packages to home-manager externally.
        This, for example, allows installing packages at home-level on a per-system basis.
      '';
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
