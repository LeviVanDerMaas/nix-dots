import { Astal, Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import AstalApps from "gi://AstalApps";
import Graphene from "gi://Graphene";
import { createState, For } from "gnim";
import { range } from "utils";

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;

type ApplauncherProps = {
    listSize?: number;
    appNameLength?: number;
};

export default function Applauncher({
    listSize = 9,
    appNameLength: appNameMaxLength = 40
}: ApplauncherProps) {
    const apps = new AstalApps.Apps();
    const [appList, setAppList] = createState(new Array<AstalApps.Application>());

    let contentBox: Gtk.Box;
    let searchEntry: Gtk.Entry;
    let win: Astal.Window;

    function search(text: string) {
        if (text === "") {
            print("Wiped app list")
            setAppList([]);
        } else {
            setAppList(apps.fuzzy_query(text).slice(0, listSize));
        }
    }

    function launch(app?: AstalApps.Application) {
        print("Launch fired")
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
                    win.hide();
                    print(appList.get().length)
                    launch(appList.get()[i - 1]);
                    return;
                }
            }
        }
    }

    function clickreleaseHandler(_g: Gtk.GestureClick, _n: number, x: number, y: number) {
        const [, rect] = contentBox.compute_bounds(win);
        const position = new Graphene.Point({ x, y });

        if (!rect.contains_point(position)) {
          win.visible = false;
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

    return <window
        application={app}
        name="applauncher"
        exclusivity={Astal.Exclusivity.IGNORE}
        keymode={Astal.Keymode.EXCLUSIVE}
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        $={(self) => win = self}
        onNotifyVisible={notifyVisibleHandler}
    >
        <Gtk.EventControllerKey onKeyPressed={keypressHandler} />
        <Gtk.GestureClick onReleased={clickreleaseHandler} />
        <box
            $={(self) => (contentBox = self)}
            orientation={Gtk.Orientation.VERTICAL}
        >
            <entry 
                $={(self) => searchEntry = self}
                onNotifyText={({text}) => search(text)}
            />
            <Gtk.Separator visible={appList((l) => l.length > 0)} />
            <box orientation={Gtk.Orientation.VERTICAL}>
                <For each={appList}>
                    {(app, index) => <button onClicked={() => launch(app)}>
                        <box orientation={Gtk.Orientation.HORIZONTAL}>
                            <image iconName={app.iconName} />
                            <label label={app.name} maxWidthChars={appNameMaxLength} wrap />
                            <label label={index((i) => `Alt+${i + 1}`)} 
                                halign={Gtk.Align.END}
                                hexpand 
                            />
                        </box>
                    </button>}
                </For>
            </box>
        </box>
    </window>
}
