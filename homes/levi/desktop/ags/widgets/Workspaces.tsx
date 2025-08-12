import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { createBinding, For, With } from "ags";

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
    // TODO: Fix a bug where .focus() will not actually work for named or special workspaces because
    // under the hood it just uses hyprlands `workspace` dispatcher, which will interpret negative ids
    // as a relative numbered workspace instead of a named or special one.
    const ws = typeof wsn === "number" ? 
        HYPRLAND.get_workspace(wsn) : 
        HYPRLAND.get_workspace_by_name(wsn);

    if (!ws) {
        return <button
            class="WorkspaceButton non-existent"
            onClicked={() => {print(wsn); HYPRLAND.dispatch("workspace", String(wsn))}}
        >
            {String(wsn)}
        </button>
    }

    return <button
        class="WorkspaceButton"
        onClicked={() => ws.focus()}
    >
        {ws.name}
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
    // Aditionally, add any workspaces that we specified based on id or name (regardless of their existance).
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
                wss.filter(ws => ws.id >= 1), 
                nonExistentNumbered?.filter(n => !HYPRLAND.get_workspace(n))
            ) as number[])
            .sort((a, b) => a - b) : [];

        const namedWss = listNamed ?
            whichToRender(
                // Digging in Compositor source code shows namedworkspaces have id of -1337 or lower
                wss.filter(ws => ws.id <= -1337), 
                nonExistentNamed?.filter(n => !HYPRLAND.get_workspace_by_name(n))
            ) : [];

        const specialWss = listSpecial ?
            whichToRender(
                // Digging in Compositor source code shows special workspaces have idea in range [-99, -2]
                wss.filter(ws => ws.id >= -99 && ws.id <= -2),
                nonExistentSpecial?.filter(n => !HYPRLAND.get_workspace_by_name(n))
            ) : [];

        return numberedWss.concat(namedWss, specialWss)
    })

    // return <box><With value={workspacesToRender}>{(value) => {print(value); return <box/>}}</With></box>
    return <box>
        <For each={workspacesToRender}>
            {ws => WorkspaceButton(ws)}
        </For>
    </box>
}
