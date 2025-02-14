{ config, ... }:

let
  rcfilename = "ripgreprc";
in
{
  programs.ripgrep.enable = true;
  home.sessionVariables.RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/${rcfilename}";
  # Be careful, in a ripgreprc each line should be exactly one argument, so if you are
  # inserting a flag then do NOT add spaces between the flag and its argument.
  xdg.configFile."${rcfilename}".text = ''
    --hidden
    --glob=!.git/*
    --glob=!/nix/store/*
  '';
}
