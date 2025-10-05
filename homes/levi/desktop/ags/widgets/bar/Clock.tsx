import { Gtk } from "ags/gtk4";
import { createPoll } from "ags/time";
import GLib from "gi://GLib";

type timeFormat = {
    format?: string,
    timeZone?: string
};

type ClockProps = timeFormat & {
    extraClocks?: timeFormat[]
    withCalendar?: boolean
};

// TODO: Might wanna make it so that if the clock only shows minutes,
// we only actually redraw the clock every minute. Though idk if 
// that really matters under modern hardware.
const dateTime = createPoll(GLib.DateTime.new_now_local(), 1000, () => {
    return GLib.DateTime.new_now_local();
});

function time({format = '%R', timeZone}: timeFormat) {
    let localeTime;
    if (timeZone) {
        const tz = GLib.TimeZone.new_identifier(timeZone);
        localeTime = dateTime.as(t => t.to_timezone(tz));
    } else {
        localeTime = dateTime;
    }
    return localeTime.as(t => t?.format(format) ?? "FMT ERR");
}

function clockLabel(tf: timeFormat) {
    return <label 
        justify={Gtk.Justification.CENTER}
        useMarkup
        label={time(tf)}
    />;
}

export default function Clock({
    format = '%R',
    extraClocks = [],
    withCalendar = false,
    timeZone,
}: ClockProps) {
    const mainClockLabel = clockLabel({format, timeZone});
    const extraClockLabels = extraClocks.length > 0 &&
        extraClocks.map(tf => clockLabel(tf));
    const calendar = withCalendar &&
        <Gtk.Calendar
            // Makes dates 'unselectable' by just setting the selected date to the current one,
            // which is what is selected by default.
            // TODO: Could do this more cleanly by modifying css to makke selected and unselected
            // dates appear the same. ALSO current date doesn't automatically roll over.
            $={self => self.connect("day-selected", () => {self.select_day(dateTime.get())})}
        />;

    // If we have nothing to expand when we click on the clock, return just label instead of
    // full popover. That also ensures the user can't click on it and get an empty popover.
    if (!(extraClockLabels || calendar)) {
        return mainClockLabel;
    } else {
        return <menubutton> 
            {mainClockLabel}
            <popover>
                <box orientation={Gtk.Orientation.VERTICAL}>
                    {extraClockLabels}
                    {calendar}
                </box>
            </popover>
        </menubutton>;
    }
}
