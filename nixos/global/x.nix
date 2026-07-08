{
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      options = "caps:escape_shifted_capslock";
      variant = "";
    };
  };
}
