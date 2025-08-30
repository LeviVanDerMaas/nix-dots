import Gtk from "gi://Gtk";
import { createBinding, For } from "ags";
import app from "ags/gtk4/app"
import Bar from "widgets/bar/Bar"
import style from "styles/style.scss"
import Applauncher from "widgets/applauncher/Applauncher";

app.start({
    css: style,
    client() {
        print("An instance is already running!");
    },

    main() {
        const monitors = createBinding(app, "monitors");
        const applauncher = Applauncher({});
  
        return <For each={monitors} cleanup={(win) => (win as Gtk.Window).destroy()}>
            {(monitor) => Bar(monitor)}
        </For>
    },
})
