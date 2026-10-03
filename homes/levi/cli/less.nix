{ pkgs, ... }:

{
  programs.less = {
    enable = true;

    # Use a wrapper to set default options for less. The reasons we use a wrapper
    # instead of the LESS env var or the lesskey file's env section is:
    # 1. Many programs set sensible defaults for less through the LESS env var;
    #    but if LESS already exists they ignore or override it. This does not
    #    sound like a big deal until you encounter this with most programs.
    # 2. Setting LESS via lesskey will overide any LESS env var inherited from
    #    the parent, running into the above problem again.
    # 3. This way we set defaults transparently, so it does not interfere with
    #    the way external programs set defaults for less.
    # As such we should also prefer setting only options that are unlikely to interfere
    # with any others set by default by other programs. If we want to invoke less with
    # one of these flags removed, call with -+<flagname>
    package = pkgs.fns.wrapPkgExe {
      package = pkgs.less;
      makeWrapperArgs = [
        "--add-flags"
        "-R --use-color -DEy-d -DNk -DPm --search-options=W -i --incsearch"
      ];
    };
  };

  # in Kitty, makes less render nerd font PUA characters (glyphs and such).
  # https://github.com/ryanoasis/nerd-fonts/wiki/FAQ-and-Troubleshooting#less-settings
  # NOTE: there might be issues if you set "narrow symbols" in kitty.conf.
  # NOTE: The reason you don't wanna set this globally is because not all terminals handle this.
  programs.kitty.environment.LESSUTFCHARDEF = "e000-e09f:w,e0a0-e0bf:p,e0c0-f8ff:w,f0001-fffff:w";
}
