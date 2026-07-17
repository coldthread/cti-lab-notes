#!/bin/bash
# Build Mode: no sleep, no lock, screen stays on

gsettings set org.cinnamon.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.cinnamon.desktop.screensaver lock-enabled false
gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled false

notify-send "Build Mode Active" "Sleep disabled. Screen lock disabled."
