{
  programs.fd = {
    enable = true;
    extraOptions = [
      "--hidden"
    ];
  };

  xdg.configFile."fd/ignore".source = ./_rg_fd_ignore;
}
