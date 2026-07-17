#!/bin/bash
LAST=""
while true; do
    CURRENT=$(wmctrl -d | grep '\*' | awk '{print $1}')
    if [ "$CURRENT" != "$LAST" ]; then
        LAST="$CURRENT"
        bash ~/scripts/workspace-wallpaper.sh
    fi
    sleep 0.5
done
