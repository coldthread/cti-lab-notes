#!/bin/bash
# Secure Mode: screen off at 5 min, shutdown at 15 min, lock enforced

gsettings set org.cinnamon.desktop.session idle-delay 300
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 900
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'shutdown'
gsettings set org.cinnamon.desktop.screensaver lock-enabled true
gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled true

notify-send "Secure Mode Active" "Screen off: 5 min. Shutdown: 15 min. Lock enforced"
