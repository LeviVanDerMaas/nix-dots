<!-- vim: set tw=80 spell: -->
# Personal NixOS + Home Manager configuration

My personal NixOS and Home Manager configuration, used to manage multiple
systems. The configuration follows a modular structure centered around a
**shared-by-default** approach, while still allowing for any device-specific
tweaks from just a single file. This makes it easy to keep a uniform setup
across systems and make changes or extend it on the fly without any hassle.

I began daily-driving NixOS halfway through 2024, but this repo was created in
2026 after heavily revamping my 300+ commit "temporary" config to make it easier
to apply changes and maintain for long-term use.

## Structure

- `nixos/` and `homes/` contain the shared configurations for NixOS and Home
  Manager, respectively. For both NixOS and Home Manager, options for custom
  modules are defined under the `config.modules.<moduleName>` attribute.

  The Home-Manager configurations are intended to be used through Home-Manager's
  NixOS module and built together with the NixOS configuration, as some
  (default) settings in the Home-Manager configurations are derived from the
  NixOS configuration under which they are built. However, they are in principle
  also designed to usable through the stand-alone `home-manager` tool; I don't
  test this rigorously, though.

- `systems/` contains the entry points for each individual system, as well as
  any system-specific configuration tweaks. This can also include
  system-specific tweaks to Home Manager, by passing an extra module with these
  tweaks to Home Manager from here.

- `overlays/` contains nixpkgs overlays to be used by both the NixOS and Home
  Manager configurations.

- `fns/` contains custom Nix functions and values used throughout the config.
  Most of it can be imported simply from `fns/default.nix`, but anything that
  depends on an instance of `nixpkgs` for its functionality is grouped under
  `fns/packages`, and is to be imported separately from the other features of
  `fns`.

  This is because an instance of `nixpkgs` is expensive, so it is
  preferable to reuse one instead. For example, in order to reuse the `pkgs`
  instance used by NixOS configurations, there is an overlay in `overlays/` that
  has all functions under `fns/packages`: this overlay can the be used in a
  NixOS configuration. This is not a concern with instances of `lib`, because
  these are already cheap and you get one for free when building a NixOS or
  Home-Manager configuration through a flake anyway.

- `assets/` contains non-config files, such as wallpapers.

### System-Specific configuration

The modular structure combined with the **shared-by-default** approach makes it
easy to manage all system-specific configuration from a single file per system,
e.g. as I do in `systems/<system>/configuration.nix`. For the same reason, I
often don't write custom options for modules when not needed for my purposes:
should they be needed down the line, it's very easy to add them without any
additional integration work.

## Systems

- **boo**: My primary desktop, used for everything from study and work to gaming
and hobby projects, and behind which I spend a considerable portion of both my
leisure and non-leisure time.

- **lucy**: My laptop, primarily used for study and work.

- **buffon**: A desktop I occasionally use for similar purposes as *boo*,
although it has older hardware and a somewhat more haphazard setup.
