{ pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = with pkgs; [
    (sddm-astronaut.override {
      themeConfig = {
        background = "${./background.png}";
        FullBlur = "false";
        PartialBlur = "false";
        OverrideTextFieldColor="#FFFFFF";
        AccentColor="#CF0700";
      };
    })
  ];
}
