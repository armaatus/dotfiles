#!/bin/sh
# Shrink the Simulator's tile to the window's natural width so the other
# windows on the workspace take the remaining space instead of a 50/50 split.
# The Simulator window has a fixed aspect ratio and refuses to be resized,
# but its tile can be sized to match it exactly.

PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Give AeroSpace a moment to finish moving/tiling the new window.
sleep 1

width=$(osascript -e 'tell application "System Events" to tell process "Simulator" to get item 1 of (get size of window 1)')
win_id=$(aerospace list-windows --monitor all --app-bundle-id com.apple.iphonesimulator --format '%{window-id}' | head -1)

if [ -n "$width" ] && [ -n "$win_id" ]; then
  aerospace resize --window-id "$win_id" width "$width"
fi
