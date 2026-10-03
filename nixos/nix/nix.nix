{ pkgs, fns, outputs, config, flake, lib, ... }:

let
  nixpkgs-config-file = fns.rootRel "nixpkgs-config.nix";
in
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];

    # Read note below to understand what keep-{derivations,outputs} actually do
    keep-derivations = true;
    keep-outputs = true;

    auto-optimise-store = true;
  };

  # NOTE: There is weird, undocumented interaction between `nix.settings.nixPath` and
  # `nixpkgs.flake.setNixPath`. When you explicitly set `nix.settings.nixPath`, you should
  # also include the values `nixpkgs.flake.setNixPath` would have set for it (if true,
  # which it is by default for flakes), otherwise its effects are silently overriden.
  # https://github.com/NixOS/nixpkgs/issues/568431
  nix.nixPath =
    # The first two values are what would have been set by `nixpkgs.flake.setNixPath`
    [ "nixpkgs=flake:nixpkgs" ] ++ (lib.optional config.nix.channel.enable "/nix/var/nix/profiles/per-user/root/channels")
    # Add nixpkgs-overlays to NIX_PATH, see nixpkgs manual for why.
    ++ [ "nixpkgs-overlays=/etc/nix/nixpkgs-overlays.nix" ];


  nixpkgs = {
    config = import nixpkgs-config-file;
    overlays = builtins.attrValues outputs.overlays;
  };

  # Also use the nixpkgs config globally when using various Nix tools in impure mode.
  # 'config.nix` is searched for at NIXPKGS_CONFIG, which defaults to `/etc/nix/nixpkgs-config.nix`
  # Overlays are searched for in the NIX_PATH at `nixpkgs-overlays`
  # NOTE: THESE WILL TAKE PRECEDENCE OVER FILES IN ~/.config
  environment.etc."nix/nixpkgs-config.nix".source = nixpkgs-config-file;
  environment.etc."nix/nixpkgs-overlays.nix".text =
    let
      fRef = builtins.flakeRefToString { type = "path"; path = flake.sourceInfo.outPath; narHash = flake.narHash; };
    in
    # Once nix is at version 2.35, you can replace this hack by just using a (relative) path literal with getFlake 
    # (Do this in a seperate file under this flake, that you then symlink too, like for nixpkgs-config.nix)
    # https://github.com/NixOS/nix/pull/15290
    pkgs.fns.checkPkgVersion'
      pkgs.nix
      "2.34.8"
      ''builtins.attrValues ((builtins.getFlake "${fRef}").overlays)'';
}

# Note on garbage collection of derivations and build-time-only outputs:
# After doing some digging through the manual and EDolstra's thesis:
# - Live store paths are all store paths reachable through the references of all
#   GC-roots.
# - In the case of derivations, these references are *exactly* the union of:
#   the store paths to all of the derivation's inputs (inputSrcs; e.g. C
#   compiler) AND the store paths to all of the derivations that must be built
#   before this derivation can (inputDrvs; e.g. derivation that builds the C
#   compiler).
# - keep-derivations will keep a derivation live if its output is live. Since a
#   derivation references all its input derivations, a live output under this
#   option will recursively make all derivations needed to build it live.
# - keep-outputs will keep the outputs of all live derivations live as well
#   (whereas ordinarily an output is live only if registered as root or
#   referenced by another live path).
# - This means that combining keep-derivations and keep-outputs will
#   transitively prevent garbage collection of all build-time-only inputs of a
#   live output (like those in your runtime environment).
