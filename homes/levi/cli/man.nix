{
  programs.man.enable = true;
  home.sessionVariables = {
    # Visually distinguish bold and underlined words with different colors on manpages.
    MANPAGER = "less -R --use-color -Dd+b -Du+r";
    MANROFFOPT = "-c"; # Needed for colors to work cuz of tech reasons and terminals like kitty.
  };
}
