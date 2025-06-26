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
    rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
    hash = "sha256-OFTHrrBeFw/dGlGTHp2hKIz7pUbf9g2yMLkQTvDWk5o=";
    sparseCheckout = [ "themes" ];
  };

  "catppuccin-yazi-${flavor}-${accent}" = final.stdenvNoCC.mkDerivation {
    name = "catppuccin-yazi-${flavor}-${accent}";
    src = final.fetchgit {
      url = "https://github.com/catppuccin/yazi.git";
      rev = "1a8c939e47131f2c4bd07a2daea7773c29e2a774";
      hash = "sha256-DogpoUbqR7YL8hBTCxRR385AGKmVJ41pBmq1QCB7N1s=";
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
