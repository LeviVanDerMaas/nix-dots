import Gtk from "gi://Gtk";
import { createBinding, For } from "ags";
import app from "ags/gtk4/app"
import Bar from "./widgets/Bar"
import style from "styles/style.scss"

app.start({
    css: style,
    client() {
        print("An instance is already running!");
    },

    main() {
        const monitors = createBinding(app, "monitors");
  
        return <For each={monitors} cleanup={(win) => (win as Gtk.Window).destroy()}>
            {(monitor) => Bar(monitor)}
        </For>
    },
})
