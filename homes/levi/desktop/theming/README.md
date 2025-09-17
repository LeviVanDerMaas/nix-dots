# Qt and Breeze outside of Plasma, using qtct

Getting Breeze to work (mostly) properly outside of Plasma, especially if you
want to do a different color-scheme than the default Breeze light, and without
setting QT_QPA_PLATFORMTHEME=kde (do not do this, it will break some features
in QT apps when not actully running under kde), is a hassle but possible. 

Breeze uses traditional Qt color schemes (via QPallete), but it also uses extra
configuration stored in kdeglobals for further tuning. If you are using Breeze
without QT_QPA_PLATFORMTHEME=kde (provided you have
`kdePackages.plasma-integration` installed, which provides the actual
platformtheme) you will need to configure both in order to get Breeze to work
properly when using non-default colorschemes. Without either the theme will not
color everything properly, especially in KDE-native apps.

I've found that the easiest way to set up a proper config for a given Breeze
colorscheme is:
- First get and set that theme within a Plasma DE and then copy
the color config from the resulting kdeglobals file. 
- Then in qt5/qt6ct, set Breeze as the theme and set "Color scheme" to one of the qtct builtins, then to 
  "Style's colors". You should now have a color scheme that mostly works, but some disabled buttons and fields may
  still give the color set by the previous color scheme (that is, no color seems to get applied by "Style's theme" at all,
  so qtct just sticks to whatever the previous color was for those
  elements).
- You should correct these wrong colors manually in the config file. The easiest way I found to figure
  out exactly which colors these are is to make a copy of the current color pallete config file, then set the color palette to a builtin qtct theme again but
  different from the one set previously, then switch back to "Style's colors" again and then compare the current color config file with the copy you
  made of the previous versions to find the exact positions where the color values changed. Manually set the colors to the desired values at those positions
  and you're done.

Alternatively if someone made a colorscheme specifically for qtct that
corresponds to a given colorscheme that KDE has for Breeze, you can just
install and set that as the colorscheme and that should probably also do the
trick. In Catppuccin's case I noticed that the color pallete for the KDE
distribution has more subdued button which I find look nicer, so I used
the aforemetnon method.
