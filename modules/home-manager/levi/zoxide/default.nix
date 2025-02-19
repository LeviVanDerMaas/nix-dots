{
  programs.zoxide.enable = true;
  # Disables error message warning of potential error in config
  # (there is none, this message suddenly started appearing after
  # an update and an issue has already been mentioned on gh.)
  # At some point this should probably be removed again, once this
  # has been fixed upstream.
  home.sessionVariables._ZO_DOCTOR = 0;
}
