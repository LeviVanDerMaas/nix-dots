{ self, pkgs, fns, config, lib, ... }:

let
  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    dotsDir = lib.mkOption {
      type = lib.types.path;
      default = /home/levi/.dots;
      description = ''
        Directory on the system where this flake is developed.
        'etc/nixos/flake.nix', will symlink to it, which means nixos-rebuild
        will by default use the `--flake` flag with this directory. Aditionally,
        it will be added to the NIX_PATH under `<dots>`.
      '';
    };
    addFlakeOverlaysToSystem = lib.mkEnableOption ''
      Enabling this makes this flake's overlays available to the system as an
      importable list under `<nixpkgs-overlays>` (see "Install overlays via
      configuration lookup" in the nixpkgs manual). As a result, any Nix tools
      and scripts that use a nixpkgs instance (as well as general imports of
      nixpkgs) will also have these overlays set when used in impure mode. The
      downside of this is that it forces the flake to be copied to the store
      whenever rebuilding the system.
    '';
  };

  config = {
    # NOTE: There is weird, undocumented interaction between `nix.settings.nixPath` and
    # `nixpkgs.flake.setNixPath`. When you explicitly set `nix.settings.nixPath`, you should
    # also include the values `nixpkgs.flake.setNixPath` would have set for it (if true,
    # which it is by default for flakes), otherwise its effects are silently overriden.
    # https://github.com/NixOS/nixpkgs/issues/568431
    nix.nixPath =
      # The first two values are what would have been set by `nixpkgs.flake.setNixPath`
      [ "nixpkgs=flake:nixpkgs" ]
      ++ (lib.optional config.nix.channel.enable "/nix/var/nix/profiles/per-user/root/channels")
      ++ (lib.optional cfg.addFlakeOverlaysToSystem "nixpkgs-overlays=/etc/nix/nixpkgs-overlays.nix")
      ++ [ "fns=/etc/nix/fns" ]
      ++ [ "dots=${toString cfg.dotsDir}" ];

    environment.etc = {
      # Also use the nixpkgs config globally when using various Nix tools in impure mode.
      # 'config.nix` is searched for at NIXPKGS_CONFIG, which defaults to `/etc/nix/nixpkgs-config.nix`
      "nix/nixpkgs-config.nix".source = fns.rootRel "nixpkgs-config.nix";
      # Overlays are searched for in the NIX_PATH at `nixpkgs-overlays`
      # NOTE: If this option is set, the flake will be copied to the store!
      "nix/nixpkgs-overlays.nix" = lib.mkIf cfg.addFlakeOverlaysToSystem {
        text = ''builtins.attrValues ((builtins.getFlake ${self}).overlays)'';
      };

      "nixos/flake.nix".source = pkgs.fns.mkOutOfStoreSymlink (cfg.dotsDir + /flake.nix);
      "nix/fns".source = fns.rootRel "fns";
    };
  };
}
