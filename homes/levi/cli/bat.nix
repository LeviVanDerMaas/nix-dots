{ pkgs, lib, ... }:

let
  catppuccin-bat =
    let
      flavor = "mocha";
      rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
      hash = "sha256-OVVm8IzrMBuTa5HAd2kO+U9662UbEhVT8gHJnCvUqnc=";
    in
    pkgs.fns.fetchRawFileFromGitHub {
      inherit rev hash;
      name = "catppuccin-bat-${flavor}";
      owner = "catppuccin";
      repo = "bat";
      path = "themes/Catppuccin ${lib.toSentenceCase flavor}.tmTheme";
    };
in
{
  programs.bat = {
    enable = true;
    themes.catppuccin.src = catppuccin-bat;
    config = {
      theme = "catppuccin";
    };
  };
}
