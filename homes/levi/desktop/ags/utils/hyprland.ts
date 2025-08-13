export namespace WorkspaceIdBounds {
    export const NUMBERED_WORKSPACE_MIN_ID = 1; // As per the Hyprland wiki
    export const NUMBERED_WORKSPACE_MAX_ID = 2147483647; // As per the Hyprland wiki
    export const NAMED_WORKSPACE_MAX_ID = -1337; // Found in Hyprland's Workspace.hpp
    export const SPECIAL_WORKSPACE_MIN_ID = -99; // Found in Hyprland's Compositor.cpp
    export const SPECIAL_WORKSPACE_MAX_ID = -2; // Found in Hyprland's Compositor.cpp
}
