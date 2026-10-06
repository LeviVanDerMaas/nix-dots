{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--smart-case" # case-insensitive if all lower-case.
      "--ignore-file=${./_rg_fd_ignore}"
    ];
  };
}
