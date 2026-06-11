{ pkgs, fns, config, ... }:

{
  # user-dirs
  xdg.userDirs = {
    enable = true;
    setSessionVariables = false;
    extraConfig = {
      SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };

  # xdg-menu config
  xdg.configFile."menus/applications.menu".source =
  let
    # We use this particular one from Plasma6 because I like its setup.
    plasma-menu = fns.fetchRawFileFromGitHub {
      owner = "KDE";
      repo = "plasma-workspace";
      rev = "11e7f5306fa013ec5c2b894a28457dabf5c42bad";
      hash = "sha256-pVvOXRPvpsnhmGEAldOKpOuGJXo2cNSIQidecm5wK/Y=";
      path = "menu/desktop/plasma-applications.menu";
    };
  in
  "${plasma-menu}";
}
