{ pkgs, lib, config, ... }:

let
  cfg = config.modules.texlive;
in
{
  options.modules.texlive = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install all of Tex Live and do some additional configuration.
        *All* because I cannot be arsed to deal with the specifics of
        Latex package management.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # There is an upstream home-manager module too but it's basically useless.

    home.packages = with pkgs; [
      texliveFull # Use withpkgs to add custom Tex Live packages.
    ];
  };
}
