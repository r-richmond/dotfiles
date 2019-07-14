#!/usr/bin/env bash

# Download docsets

# Configure licensce
FILE="/Users/$USER/Dropbox/config/purchase/license4.dash-license";
[ -f "$FILE" ] && open "$FILE";

FILE="/Users/$USER/Dropbox/applications/dash/Dash.dashsync";
[ -f "$FILE" ] && open "$FILE";

# Quit Dash
osascript -e 'quit app "DASH"';
