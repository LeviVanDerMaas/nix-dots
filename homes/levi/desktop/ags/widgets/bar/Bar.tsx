import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import Workspaces from "./Workspaces";

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const time = createPoll("", 1000, "date");
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

    return <window
        application={app}
        class="Bar"
        gdkmonitor={gdkmonitor}
        anchor={TOP | LEFT | RIGHT}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        visible
    >
        <centerbox cssName="centerbox">
            <button
                $type="start"
                onClicked={() => execAsync("echo hello").then(console.log)}
                hexpand
                halign={Gtk.Align.CENTER}
            >
                <label label="Welcome to AGS!" />
            </button>
            <Workspaces $type="center"/>
            <box $type="end" />
        </centerbox>
    </window>
}
