final: prev: let
  flavor = "mocha";
  accent = "blue";
  capitalizeFirst = str: let
    first = builtins.substring 0 1 str;
    rest = builtins.substring 1 (builtins.stringLength str) str;
  in final.lib.toUpper first + rest;
in {
  "catppuccin-bat-${flavor}" = final.fetchgit {
    name = "catppuccin-bat-${flavor}";
    url = "https://github.com/catppuccin/bat.git";
    rev = "699f60fc8ec434574ca7451b444b880430319941";
    hash = "sha256-HonuDBZfXz5pXFsi88YzrWfIO6UwB7HoRLAwRKHGFCQ=";
    sparseCheckout = [ "themes" ];
  };

  "catppuccin-yazi-${flavor}-${accent}" = final.stdenvNoCC.mkDerivation {
    name = "catppuccin-yazi-${flavor}-${accent}";
    src = final.fetchgit {
      url = "https://github.com/catppuccin/yazi.git";
      rev = "5d3a1eecc304524e995fe5b936b8e25f014953e8";
      hash = "sha256-kBJ5pGaicrZy6rqHXTh2pvN7MvcbWYNhbUANLwZTul0=";
      sparseCheckout = [ "themes/${flavor}" ];
    };
    buildPhase = '' # This makes it so that the catppucchin theme also applies to the bat preview.
      mv themes/mocha/catppuccin-${flavor}-${accent}.toml theme.toml
      rm -rf themes # Discard all other themes.
      substituteInPlace theme.toml \
        --replace-warn 'syntect_theme = "~/.config/yazi/Catppuccin-${flavor}.tmTheme"' 'syntect_theme = "${final."catppuccin-bat-${flavor}"}/themes/Catppuccin ${capitalizeFirst flavor}.tmTheme"'
    '';
    installPhase = "mkdir -p $out; cp theme.toml $out/theme.toml";
  };
}
