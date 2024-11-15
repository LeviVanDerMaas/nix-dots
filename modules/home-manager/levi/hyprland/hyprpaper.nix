let
  outskirts = "${../../../../assets/wallpapers/outskirts.jpg}";
in
{
  services.hyprpaper.enable = true;
  services.hyprpaper.settings = {
    preload = [ outskirts ];
    wallpaper = [
      ", ${outskirts}"
    ];
  };
}
