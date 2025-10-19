import { Astal, Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import AstalApps from "gi://AstalApps";
import Graphene from "gi://Graphene";
import { createState, For } from "gnim";


type ApplauncherProps = {
    maxNumApps: number;
    maxNameLength?: number;
};

export default function Applauncher({
    maxNumApps = 9,
    maxNameLength = 40
}: ApplauncherProps) {
    const apps = new AstalApps.Apps();
    const [appList, setAppList] = createState(new Array<AstalApps.Application>());

    let contentBox: Gtk.Box;
    let searchEntry: Gtk.Entry;
    let win: Astal.Window;

    function search(text: string) {
        if (text === "") {
            setAppList([]);
        } else {
            const qResults = apps.fuzzy_query(text);
            setAppList(qResults.slice(0, Math.min(maxNumApps, qResults.length)));
        }
    }

    // NOTE: if we wanna do custom parsing of the .desktop's exec field:
    // use `replace(/\%[fFuUdDnNickvm]/g, '').trim()` to strip out all field codes
    // then use Glib.shell_parse_argv() to get individual args in array form.
    function launch(app?: AstalApps.Application) {
        win.hide()
        if (app) {
            return app.launch();
        }
    }

    function keypressHandler(_e: Gtk.EventControllerKey, key: number, _k: number, mod: number) {
        if (key === Gdk.KEY_Escape) {
            win.hide();
            return;
        }
        
        if (mod === Gdk.ModifierType.ALT_MASK) {
            for (let i = 1; i < 10; i++) {
                if (key === Gdk[`KEY_${i}` as keyof typeof Gdk]) {
                    launch(appList.get()[i - 1]);
                    return;
                }
            }
        }
    }

    function clickpressHandler(_g: Gtk.GestureClick, _n: number, x: number, y: number) {
        const [, rect] = contentBox.compute_bounds(win);
        const position = new Graphene.Point({ x, y });

        if (!rect.contains_point(position)) {
          win.hide();
          return true;
        }
    }

    function notifyVisibleHandler({visible}: {visible: boolean}) {
        if (visible) {
            searchEntry.grab_focus_without_selecting();
        } else {
            searchEntry.set_text("");
        }
    }

    const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;
    const { START, CENTER, END } = Gtk.Align;
    const { VERTICAL, HORIZONTAL } = Gtk.Orientation;
    return <window
        application={app}
        name="applauncher"
        anchor={TOP | BOTTOM | LEFT | RIGHT}
        exclusivity={Astal.Exclusivity.IGNORE}
        keymode={Astal.Keymode.EXCLUSIVE}
        $={(self) => win = self}
        onNotifyVisible={notifyVisibleHandler}
    >
        <Gtk.EventControllerKey onKeyPressed={keypressHandler} />
        <Gtk.GestureClick onPressed={clickpressHandler} />
        <box
            $={(self) => (contentBox = self)}
            orientation={VERTICAL}
            valign={CENTER}
            halign={CENTER}
            heightRequest={800}
        >
            <entry 
                $={(self) => searchEntry = self}
                onNotifyText={({text}) => search(text)}
                valign={START}
            />
            <scrolledwindow 
                propagateNaturalHeight={true}
                maxContentHeight={500}
                hscrollbarPolicy={Gtk.PolicyType.NEVER}
                valign={CENTER}
            >
                <box orientation={VERTICAL}>
                    <For each={appList}>
                        {(app, index) => <button onClicked={() => launch(app)}>
                            <box orientation={HORIZONTAL}>
                                <image iconName={app.iconName} />
                                <label label={app.name} maxWidthChars={maxNameLength} wrap />
                                <label label={index((i) => `Alt+${i + 1}`)} 
                                    halign={END}
                                    hexpand 
                                />
                            </box>
                        </button>}
                    </For>
                </box>
            </scrolledwindow>
        </box>
    </window>
}
