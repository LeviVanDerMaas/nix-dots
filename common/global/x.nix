{
  services.xserver = { 
    enable = true;

    xkb = {
      layout = "us";
      options = "caps:escape";
      variant = "";
    };
  };
}
