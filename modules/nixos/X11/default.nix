{
  services.xserver = { 
    enable = true;

    xkb = {
      extraLayouts.us_super_r_mod3 = {
        symbolsFile = ./xkb_symbols/us_super_r_mod3;
        description = "US-based layout with Super_R assigned to mod3 instead of mod4.";
        languages = [ "eng" ];
      };

      layout = "us_super_r_mod3";
      options = "caps:escape";
      variant = "";
    };
  };
}
