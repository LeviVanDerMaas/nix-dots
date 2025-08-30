import AstalHyprland from "gi://AstalHyprland";
import { createBinding, For } from "ags";
import { WorkspaceIdBounds as WSB } from "utils/hyprland";

const HYPRLAND = AstalHyprland.get_default();

type WorkspacesProps = {
    listNumbered?: boolean,
    listNamed?: boolean,
    listSpecial?: boolean,
    /** Lists only the workspaces that are on the monitor with the specified (Hyprland) ID or name. */
    onMonitor?: Array<number | string>,
    /** If no workspace with one of these IDs or names exists, list it */
    nonExistent?: Array<number | string>
};

function WorkspaceButton(wsn: number | string) {
    const ws = typeof wsn === "number" ? 
        HYPRLAND.get_workspace(wsn) : 
        HYPRLAND.get_workspace_by_name(wsn);

    // If wsn is non-positive convert to name because `workspace` dispatcher only accepts
    // non-negative ids. Note that Workspace.focus() does not account for this.
    if (typeof wsn === "number" && wsn < 1) {
        if (ws) {
            wsn = ws.name;
        } else {
            console.warn(`[WorkspaceButton] given id ${wsn}, no such named workspace exists. Assuming id as name.`);
            wsn = String(wsn);
        }
    }

    // Named workspaces must be prefixed with `name:` in the dispatcher and specials with `special:`
    // However, special workspaces are *already* prefixed with `special:` in their actual name.
    const dispatchParam = typeof wsn === "number" ?
        String(wsn) :
        (wsn.startsWith("special:") ? "" : "name:") + wsn;

    return <button
        class ={`WorkspaceButton ${!ws ? "non-existent" : ""}`}
        onClicked={() => HYPRLAND.dispatch("workspace", dispatchParam)}
        >
        {String(wsn)}
    </button>
}

export default function Workspaces({
    listNumbered = true,
    listNamed = true,
    listSpecial = true,
    onMonitor,
    nonExistent,
}: WorkspacesProps) {
    const nonExistentNumbered = nonExistent?.filter((n): n is number => typeof n === "number");
    const nonExistentNamed = nonExistent?.filter((n): n is string => typeof n === "string" && !n.startsWith("special:"));
    const nonExistentSpecial = nonExistent?.filter((n): n is string => typeof n === "string" && n.startsWith("special:"));

    // Given a list of workspaces, return the id's or names of those that must be rendered for this instance.
    // Aditionally, add any workspaces that we specified based on id or name (regardless of their existence).
    const whichToRender = (wss: Array<AstalHyprland.Workspace>, add?: Array<number | string>) => {
        if (onMonitor) {
            wss = wss.filter(ws => 
                onMonitor.some(mon => 
                    mon === (typeof mon === "number" ? ws.monitor.id : ws.monitor.name)
                )
            );
        }
        return wss.map(ws => ws.id as number | string).concat(add ?? [])
    }

    const workspacesToRender = createBinding(HYPRLAND, "workspaces").as(wss => {
        const numberedWss: Array<number | string> = listNumbered ?
            (whichToRender(
                wss.filter(ws => ws.id >= WSB.NUMBERED_WORKSPACE_MIN_ID), 
                nonExistentNumbered?.filter(n => !HYPRLAND.get_workspace(n))
            ) as number[])
            .sort((a, b) => a - b) : [];

        const namedWss = listNamed ?
            whichToRender(
                wss.filter(ws => ws.id <= WSB.NAMED_WORKSPACE_MAX_ID), 
                nonExistentNamed?.filter(n => !HYPRLAND.get_workspace_by_name(n))
            ) : [];

        const specialWss = listSpecial ?
            whichToRender(
                wss.filter(ws => ws.id >= WSB.SPECIAL_WORKSPACE_MIN_ID && ws.id <= WSB.SPECIAL_WORKSPACE_MAX_ID),
                nonExistentSpecial?.filter(n => !HYPRLAND.get_workspace_by_name(n))
            ) : [];

        return numberedWss.concat(namedWss, specialWss)
    })

    return <box>
        <For each={workspacesToRender}>
            {ws => WorkspaceButton(ws)}
        </For>
    </box>
}
