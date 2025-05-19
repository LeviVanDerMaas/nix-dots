# Wraps Dolphin to include some extra dependencies to make the UI render
# correctly (normally these are installed alongside Plasma. The wrapper also
# ensures Dolphin will always execute with XDG_MENU_PREFIX=plasma- in its
# environment: this allows a user to then configure mimeapps and other
# default applications (specified in kdeglobals file) for Dolphin by simply
# providing a correctly configured plasma-applications.menu. Thus, this
# overlay should let Dolphin work properly outside of Plasma with little
# extra user config.
final: prev: {
  kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
    dolphin = final.symlinkJoin {
      name = "dolphin";
      buildInputs = [ final.makeWrapper ];
      paths = [ prev.kdePackages.dolphin ];
      postBuild = let extraDeps = with final.kdePackages; [
        qtwayland # Proper wayland support
        qtsvg # Many themes (and some base ui components) need svg icon support.
        # kio-fuse # Needed to mount remote filesystems via FUSE
        # kio-extras # Extra remote filesystem protocols (sftp, fish and more)
      ]; in ''
        wrapProgram $out/bin/dolphin \
          --suffix PATH : ${final.lib.makeBinPath extraDeps} \
          --set XDG_MENU_PREFIX plasma-
      '';
    };
  });
}
