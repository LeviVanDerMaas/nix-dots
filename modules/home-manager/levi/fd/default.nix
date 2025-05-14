{
  programs.fd = {
    enable = true;
    extraOptions = [
      "--hidden"
    ];
    ignores = [
      ".git/"
      "/nix/store"
      ".nix-profile"
    ];
  };
}
