{
  programs.less = {
    enable = true;
    options = [
      # Set up some pager UI colors (don't affect displayed content).
      "-R" "--use-color" "-DEy-d" "-DNk" "-DPc"
    ];
    config = ''
      #command
      / forw-search ^W
      ? back-search ^W
    '';
  };

  # in Kitty, makes less render nerd font PUA characters (glyphs and such).
  # https://github.com/ryanoasis/nerd-fonts/wiki/FAQ-and-Troubleshooting#less-settings
  # NOTE: there might be issues if you set "narrow symbols" in kitty.conf.
  # NOTE: The reason you don't wanna set this globally is because not all terminals handle this.
  programs.kitty.environment.LESSUTFCHARDEF = "e000-e09f:w,e0a0-e0bf:p,e0c0-f8ff:w,f0001-fffff:w";
}
