{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans # Don't need serif, it uses this as fallback
      noto-fonts-color-emoji

      nerd-fonts.fira-code 
      fira-code-symbols # Fixes ligature issues in some specfic older software

      nerd-fonts.symbols-only # Generic nerd font fallback for other fonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" "Symbols Nerd Font" ];
        sansSerif = [ "Noto Sans" "Symbols Nerd Font" ];
        monospace = [ "FiraCode Nerd Font" "Symbols Nerd Font Mono" ];
      };
    };
  };
}
