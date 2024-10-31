{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-color-emoji

      fira-code
      fira-code-symbols

      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" "Symbols Nerd Font" ];
        sansSerif = [ "Noto Sans" "Symbols Nerd Font" ];
        monospace = [ "Fira Code" "Symbols Nerd Font Mono" ];
      };
    };
  };
}
