{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      fira-code
      fira-code-symbols

      nerd-fonts.symbols-only
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
