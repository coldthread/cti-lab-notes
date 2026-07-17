#!/bin/bash
# Moderate Mode: Screen off at 10 min, suspend at 1 hour, lock enabled

gsettings set org.cinnamon.desktop.session idle-delay 600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
gsettings set org.cinnamon.desktop.screensaver lock-enabled true
gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled true

notify-send "Moderate Mode Active" "Screen off: 10 min. Suspend: 1 hour. Lock enabled."
