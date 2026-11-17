{ self, pkgs, fns, config, lib, ... }:

let
  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    dotsDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = /home/levi/.dots;
      description = ''
        Directory on the system where this flake is developed.
        'etc/nixos/flake.nix', will symlink to it, which means nixos-rebuild
        will implicitly use the `--flake` flag with this directory as argument.
        Aditionally, it will be added to the NIX_PATH under `<dots>`.
      '';
    };
    addToSystem = {
      flakeOverlays = lib.mkEnableOption ''
        WARNING: If true, the full flake tree is copied to the store for any change!

        Make this flake's overlays available to the system as an importable
        list under `<nixpkgs-overlays>` on NIX_PATH. These overlays will be
        implicitly added to any nixpkgs instance used in impure mode.
      '';
      fns = lib.mkEnableOption ''
        Copies this flake's `fns/` subdir to the store, symlink it to
        etc/nix/fns, and add it to NIX_PATH under <fns>.
      '';
    };
  };

  config = lib.mkMerge [
    {
      # The default values for nix.nixPath IF this config is built via --flake.
      # They must be explicitly set depending on if --flake or not, because of this issue:
      # https://github.com/NixOS/nixpkgs/issues/568431
      nix.nixPath = [ "nixpkgs=flake:nixpkgs" ]
        ++ (lib.optional config.nix.channel.enable "/nix/var/nix/profiles/per-user/root/channels");

      # Instances of nixpkgs used in impure mode should copy the nixpkgs config used for this flake.
      environment.etc."nix/nixpkgs-config.nix".source = fns.rootRel "nixpkgs-config.nix";
    }

    # Overlays are searched for in the NIX_PATH at `nixpkgs-overlays`
    # BEWARE: When this is true the full flake tree is copied to the store for any little change.
    (lib.mkIf cfg.addToSystem.flakeOverlays {
      nix.nixPath = [ "/nix/var/nix/profiles/per-user/root/channels" ];
      environment.etc."nix/nixpkgs-overlays.nix".text =
        "builtins.attrValues ((builtins.getFlake ${self}).overlays)";
    })

    (lib.mkIf cfg.addToSystem.fns {
      nix.nixPath = [ "fns=/etc/nix/fns" ];
      environment.etc."nix/fns".source = fns.rootRel "fns";
    })

    # If /etc/nixos/flake.nix exist then nixos-rebuild implicitly uses --flake. There is no way
    # to change this (besides passing --no-flake), and this completely ignores the value of NIXOS_CONFIG.
    (lib.mkIf (cfg.dotsDir != null) {
      nix.nixPath = [ "dots=${toString cfg.dotsDir}" ];
      environment.etc."nixos/flake.nix" = lib.mkIf (cfg.dotsDir != /etc/nixos)
        { source = pkgs.fns.mkOutOfStoreSymlink (cfg.dotsDir + /flake.nix); };
    })
  ];
}
