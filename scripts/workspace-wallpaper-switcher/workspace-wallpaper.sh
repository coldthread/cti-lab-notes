#!/bin/bash
WD="$HOME/Pictures/Wallpapers"
W=("$WD/general.jpg" "$WD/research.png" "$WD/lab.png" "$WD/vm.webp")
N=$(wmctrl -d | grep '\*' | awk '{print $1}')
gsettings set org.cinnamon.desktop.background picture-uri "file://${W[$N]}"
