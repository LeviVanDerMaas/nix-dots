{ pkgs, lib, ... }:

{
  options.modules.cursorDefault = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Configure the default XCURSOR theme, that is, the cursor themes that progams
        using XCURSOR *should* default to when no other cursor theme is found or specfied.
      '';
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      # May wanna consider making a custom package that pulls 
      # just breeze cursors instead of all of breeze, should we end up
      # not using breeze as our theme in the future.
      kdePackages.breeze
    ];

    # Should suffice to have the cursors available in environment.systemPackages
    # (assuming cursor package structures output dirs appropriately) for this to detect them.
    xdg.icons.fallbackCursorThemes = [
      "breeze_cursors"
    ];
  };
}
