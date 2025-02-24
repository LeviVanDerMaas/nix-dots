{ inputs, ... }:

{
  # Wraps Dolphin to include some extra dependencies to make the UI render
  # correctly (normally these are installed alongside Plasma. The wrapper also
  # ensures Dolphin will always execute with XDG_MENU_PREFIX=plasma- in its
  # environment: this allows a user to then configure mimeapps and other
  # default applications (specified in kdeglobals file) for Dolphin by simply
  # providing a correctly configured plasma-applications.menu. Thus, this
  # overlay should let Dolphin work properly outside of Plasma with little
  # extra user config.
  dolphin-out-of-plasma = final: prev: {
    kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
      dolphin = final.symlinkJoin {
        name = "dolphin";
        buildInputs = [ final.makeWrapper ];
        paths = [ prev.kdePackages.dolphin ];
        postBuild = let extraDeps = with final.kdePackages; [
          qtwayland # Proper wayland support
          qtsvg # Many themes (and some base ui components) need svg icon support.
          # kio-fuse # Needed to mount remote filesystems via FUSE
          # kio-extras # Extra remote filesystem protocols (sftp, fish and more)
        ]; in ''
          wrapProgram $out/bin/dolphin \
            --suffix PATH : ${final.lib.makeBinPath extraDeps} \
            --set XDG_MENU_PREFIX plasma-
        '';
      };
    });
  };

  catppuccinThemes = final: prev: {
    catppuccin-bat-mocha = final.fetchgit {
      name = "catppuccin-bat-mocha";
      url = "https://github.com/catppuccin/bat.git";
      rev = "699f60fc8ec434574ca7451b444b880430319941";
      hash = "sha256-HonuDBZfXz5pXFsi88YzrWfIO6UwB7HoRLAwRKHGFCQ=";
      sparseCheckout = [ "themes" ];
    };

    catppuccin-yazi-mocha-blue = final.stdenvNoCC.mkDerivation {
      name = "catppuccin-yazi-mocha";
      src = final.fetchgit {
        url = "https://github.com/catppuccin/yazi.git";
        rev = "5d3a1eecc304524e995fe5b936b8e25f014953e8";
        hash = "sha256-kBJ5pGaicrZy6rqHXTh2pvN7MvcbWYNhbUANLwZTul0=";
        sparseCheckout = [ "themes/mocha" ];
      };
      buildPhase = '' # This makes it so that the catppucchin theme also applies to the bat preview.
        mv themes/mocha/catppuccin-mocha-blue.toml theme.toml
        rm -rf themes # Discard all other themes.
        substituteInPlace theme.toml \
          --replace-warn 'syntect_theme = "~/.config/yazi/Catppuccin-mocha.tmTheme"' 'syntect_theme = "${final.catppuccin-bat-mocha}/themes/Catppuccin Mocha.tmTheme"'
      '';
      installPhase = "mkdir -p $out; cp theme.toml $out/theme.toml";
    };
  };
}
