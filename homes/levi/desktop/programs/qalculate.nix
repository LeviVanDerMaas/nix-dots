{ pkgs, ... }:

{
  # The cli program and the GUI version have different config files.
  # Though I think the cli one also becomes the "defaults" for the gui ones.
  # Anyway, the HM module only affects the cli one: qalc.cfg
  programs.qalculate.enable = true;
  home.packages = with pkgs; [
    qalculate-qt
  ];
}
