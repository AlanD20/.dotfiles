#!/usr/bin/python
import i3ipc

#
# Usage:
#
# Run this binary when you startup your sway so that it always listen
#

transparency_val = "0.85"
ipc = i3ipc.Connection()
prev_focused = None

for window in ipc.get_tree().leaves():
    if window.focused:
        prev_focused = window
    else:
        window.command("opacity " + transparency_val)


def on_window_focus(ipc, focused):
    global prev_focused
    current = focused.container
    if prev_focused is None or current.id != prev_focused.id:
        current.command("opacity 1")
        if prev_focused is not None:
            prev_focused.command("opacity " + transparency_val)
        prev_focused = current


def on_window_close(ipc, event):
    global prev_focused
    if prev_focused is not None and event.container.id == prev_focused.id:
        prev_focused = None


ipc.on("window::close", on_window_close)


ipc.on("window::focus", on_window_focus)
ipc.main()
