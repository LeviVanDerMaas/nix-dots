{ pkgs... }:

pkgs.writeShellScript "exchangeWindows" ''
# A script that will swap all windows between two workspaces and will
# TRY to restore the original tiling hierarchy on the new workspaces.

getWindowsAtWorkspace() {
  echo $(hyprctl clients -j | jq -rc --argjson ws $1 'map(select(.workspace.id == $ws))')
}
filterOrderTiled() {
  echo $(jq -rc 'map(select(.floating | not)) | sort_by(.size[0] * .size[1]) | reverse' <<< $1)
}
windows1=$(getWindowsAtWorkspace "$1")
windows2=$(getWindowsAtWorkspace "$2")
tiled1=$(filterOrderTiled "$windows1")
tiled2=$(filterOrderTiled "$windows2")

# Make all tiled windows floating; 
dispatchToWindows() { #first provide windows json, then dispatcher with args
  windows=$1
  shift
  jq -rc .[].address <<< $windows | while read -r address; do
    hyprctl dispatch $@ 'address:'$address
  done;
}
dispatchToWindows "$tiled1" 'setfloating'
dispatchToWindows "$tiled2" 'setfloating'

# Move ALL windows to other workspace (do for both workspaces before next step);
dispatchToWindows "$windows1" 'movetoworkspacesilent' $2','
dispatchToWindows "$windows2" 'movetoworkspacesilent' $1','

# Now reposition and resize all windows to match the state of these on the
# previous workspace (regardless of if they were tiled or floating before). If
# we then, in the next step, retile all previously tiled windows in order from
# largest to smallest area, the resulting tiling should approximate the
# original tiling quite well.
reapplyPositioningToWindows() {
  jq -rc '.[]' <<< $1 | while read -r window; do
    w=$(jq -rc .size[0] <<< $window)
    h=$(jq -rc .size[1] <<< $window)
    x=$(jq -rc .at[0] <<< $window)
    y=$(jq -rc .at[1] <<< $window)
    address=$(jq -rc .address <<< $window)
    hyprctl dispatch resizewindowpixel "exact $w $h, address:$address"
    hyprctl dispatch movewindowpixel "exact $x $y, address:$address"
  done;
}
reapplyPositioningToWindows "$windows1"
reapplyPositioningToWindows "$windows2"

# Now do retiling. Retiling behaviour is a bit finnicky, as there seems to be a
# bug where dispatching a window to tile mode when it is on a different
# workspace than the active one will cause it to move to the active one.
# Furthermore, retiling appears to depend on the position of the cursor (even
# if options like dwindle:smart_split are off), where the compositior will try
# to tile the window in at the position of the cursor rather than the window
# itself (also seems to tie into aforementiond bug). So we work around all this
# by focussing on the workspace where we are currently retiling beforehand
# (which can be accomplished by focussing on the window to be tiled), and right
# before each individual tile we move the cursor to the top-left of the window
# to be tiled. If we care to (I don't at the moment) we could just add something
# to the end of the script to restore our cursor to a given position or window afterward)
# BUG: if you tile a floating window on a different workspace than the active one, it will
# move to the active one and cause some other temporary rendering issues.
# https://github.com/hyprwm/Hyprland/issues/4967
retileWindows() {
  jq -rc .[].address <<< $1 | while read -r address; do
    hyprctl dispatch focuswindow 'address:'$address
    hyprctl dispatch movecursortocorner 3
    hyprctl dispatch settiled 'address:'$address
  done;

}
hyprctl dispatch workspace $2
retileWindows "$tiled1"
hyprctl dispatch workspace $1
retileWindows "$tiled2"
''
