{ pkgs, overlays, ... }:

# NOTE: Read the lengthy comment below on how this makes MIME-types work
# outside of Dolphin with Plasma. Also note that without
# xdg-desktop-portal-kde, Dolphin will not be able to pop-up a "choose
# application to open with" menu when trying to open a file if the QT
# platformtheme has also been forced to KDE. Furthermore, note
# that Dolphin relies on kdeglobals to tell it what default apps to use in
# cases where MIME-types are insufficient: e.g. if a MIMEtype tells Dolphin to
# open something with Neovim, then kdeglobals will tell it what terminal to
# open it with. In cases where Dolphin cannot determine a default application
# it will, depending on the file-type, either:
# - Make a hard-coded assumption and fail if that application is not installed.
# - Use the first app KService has found to be suitable, if any, or fail.
# Which case applies seems to depend on whether Plasma comes with a default app
# for case 1.
{
  nixpkgs.overlays = [ overlays.dolphin-out-of-plasma ];
  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.ark # File archiver by KDE, very integrated with Dolphin.
  ];

  # This is needed to make the "open with" features of Dolphin work properly
  # when the platformtheme is forced to kde. Unfortunately it does depend
  # on plasma-workspace, so you may want to consider commenting this out and
  # setting all your MIMEtypes manually to work around this.
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
}






# NOTES ON GETTING MIME-TYPES TO WORK OUTSIDE of PLASMA: 

# Below is my understanding of why Dolphin has trouble with MIMEtypes when running
# outside of Plasma and what you can do to fix it. If you don't care about the
# why, the bottom paragraph contains all the info you need to fix it. This explanation
# is mainly here because I was curious and didn't want my findings to be "forgotten" to
# myself, plus it might actually be useful when dealing with similar issues when 
# installing other DE-integrated apps.
#
# In order to obtain MIME-types and construct the "open with" menu that Dolphin
# opens if it was not able to match a MIME-type to a file, Dolphin relies on
# KService (provided by kdePackages.kservice). KService is a library explicitly
# designed for querying info about installed applications and associated file
# types. To do so, KService maintains the 'KService desktop file system
# configuration cache' (ksycoca). This binary cache is constructed and updated
# using 'kbuildsycoca6' (can be manually invoked as a CLI program with the name, even has a
# man page), which itself is part of KService. The ksycoca file is normally stored
# in the system's designated cache location, so typically $XDG_CACHE_HOME.
# KService is usually smart enough to build/update the cache when necessary, e.g.
# it can usually detect when programs have been added or removed and when
# mimeapps.list has been updated (even if you edited it manually by hand outside
# of Plasma)**. But even if this does go wrong and the cache gets outdated, this
# should not stop Dolphin from being able to open files using MIMEtypes.
#
# What is the problem with MIME-types in Dolphin then? Well, in order to structure
# the "open with" menu, an applications.menu file as described by the XDG Menu
# Specification is required***: kbuildsycoca6 will cache the menu structure in
# applications.menu into the ksycoca file, and KService then uses this to actually
# construct the menu for Dolphin. If application.menu cannot be found or is
# structured erroneously, a warning will be emitted by kbuildsycoca6 but it will
# still produce a cache file. For whatever reason, outside of Plasma,
# kbuildsyscoca6 will then never correct the wrong/missing information in the
# cache when updating it, even if a correct applications.menu file is provided
# later. Whenever this happens, Dolphin can no longer deal with MIMEtypes because
# it also seems to require the "open with" menu to be created correctly to do so
# (or perhaps the ksycoca cache is simply corrupted in this state?).
#
# It is obvious why this goes wrong when installing Dolphin without installing
# Plasma, since there is no applications.menu file provided by default. But even
# if we do install Plasma alongside Dolphin (or rather, Dolphin as part of
# Plasma), why does this still go wrong outside Plasma? Well, per the XDG Menu
# Specification, DE's should prefix their own applications.menu with a custom
# prefix, 'plasma-' in the case of Plasma, and anything that pertains to reading
# an application.menu file should read it from
# `$XDG_CONFIG_DIRS/menus/${XDG_MENU_PREFIX}applications.menu`. This means that
# installing Plasma will actually give us a file `plasma-applications.menu`, but
# in a WM like Hyprland by default kbuildsycoca6 and Dolphin will instead assume it is named
# `applications.menu` because WM's should not set $XDG_MENU_PREFIX to anything.
#
# An easy fix would be to download the default plasma-applications.menu from
# Plasma Workspace, and then symlink `$XDG_CONFIG_DIRS/menus/applications.menu` to
# it. However, if we then want to use software that relies on application.menu
# files from different DE's outside of said DE's, that may break stuff as well. A
# better alternative is to instead overlay Dolphin with a wrapper that always sets 
# `$XDG_MENU_PREFIX=plasma-` (which is unlikely to cause any issues for other
# packages as Dolphin is evidently built under the assumption that this is the
# case anyway). It is not necessary to install kdePackages.kservice seperately
# since it is a dependency of Dolphin, but if you do want to manually update/build
# ksycoca then you should also ensure `$XDG_MENU_PREFIX=plasma-` is always set
# when executing kbuildsyscoca6 (which you could also do with an overlaid
# wrapper). Also, MAKE SURE THERE EXISTS NO ksycoca CACHE IN YOUR $XDG_CACHE_HOME
# PRIOR TO THIS, just rm -rf it if it does: that can also be used as an
# alternative method to trigger a full rebuild of the cache if you do not wish to
# install kdePackages.kservice to your environment.
#
#
#     * Also known as 'KDE SYstem COnfiguration CAche', which is where the name
#     ksycoca comes from; although the man names it as the former, which also
#     makes more sense since a KDE system actually uses various caches besides
#     ksycoca.
#    
#     ** One can also run 'kbuildsycoca6' manually to force an update or a full
#     rebuild with the --noincremental flag. Note that if your directory
#     structure has not changed then the SHA-1 hash in the name of the cache
#     file stays the same, but it does actually modify file.
#    
#     *** A default one is provided by Plasma Workspace (pkgs.plasma-workspace)
#     under plasma-applications.menu. This is also used to structure the
#     application menu in KDE's application launcher, among a variety of other
#     things. It fortunately works without issue even if downloaded and used
#     outside Plasma.
