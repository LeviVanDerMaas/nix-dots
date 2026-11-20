{ pkgs, ... }:

{
  home.packages = [
    (pkgs.fns.wrapAllPkgExes {
      # Workaround for new Discord A/B test where they force open Discord on
      # the Quests page, which is usually just a big advert for some game.
      # This can probably be removed in the future
      package = pkgs.discord;
      makeWrapperArgs = [ "--add-flag" "discord://-/channels/@me" ];
    })
  ];
}
