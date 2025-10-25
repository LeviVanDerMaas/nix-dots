{ config, ... }:

{
  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      diffToolMode = true;
    };
  };

  programs.bash.shellAliases.diff = "${config.programs.difftastic.package}/bin/difft";
}
