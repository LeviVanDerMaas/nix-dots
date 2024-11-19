{
  services.xserver.enable = true;
  services.xserver.xkb = {
    extraLayouts.us_super_r_mod3 = {
      symbolsFile = ./symbol_maps/us_super_r_mod3;
      description = "US-based layout with super_R assigned to mod3 instead of mod4.";
      languages = [ "eng" ];
    };

    layout = "us_super_r_mod3";
    options = "caps:escape";
    variant = "";
  };
}
