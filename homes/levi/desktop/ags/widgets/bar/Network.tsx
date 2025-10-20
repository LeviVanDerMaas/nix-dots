import { Gtk } from "ags/gtk4";
import AstalNetwork from "gi://AstalNetwork?version=0.1";
import Pango from "gi://Pango?version=1.0";
import { createBinding, With } from "gnim";

const NETWORK = AstalNetwork.get_default();


// Astal hardcodes (checked on 2025-10-06) the icon names that the
// wired and wifi objects return, as well as hardcodes the logic
// that determines which icon name is currently given. This means that
// if your theme is missing certain icons for certain states that
// Astal considers (which it probably will if you aren't using Adwaita;
// e.g. Breeze does not have network-wireless-no-route, but Astal may
// set the iconName to this under certain circumstances), you're out of luck.
// As such, we create our own logic.
// TODO: Actually do what the above says and support custom icons.

export default function Network() {
    // From what I understand after going through Astal's source code and reading
    // the corresponding Vala and NM doc:
    // - Primary connection will only be unknown if there is no default route
    //   to connect over (i.e. no connected hardware device for networking) or
    //   the default route is over a device not recognized by NM.
    // - The `wifi` and `wired` propertys of the `AstalNetwork.Network` object
    //   represent the respective hardware devices managing these.
    const primaryConnectionType = createBinding(NETWORK, "primary");
    const wifi = createBinding(NETWORK, "wifi");
    const wired = createBinding(NETWORK, "wired");

    // You can just use <with> to get the wifi and wired objects,
    // since they should basically never change during runtime.
    return <menubutton>
        <image icon={}>
    </menubutton>
}
