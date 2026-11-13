#!/usr/bin/env bash
# Polybar bluetooth status: shows power state + connected device name.
# Left-click (configured in config.ini) opens blueman-manager.

if ! bluetoothctl show | grep -q "Powered: yes"; then
  echo "%{F#7F7F7F}BT off%{F-}"
  exit 0
fi

connected=$(bluetoothctl info 2>/dev/null | grep -m1 "Name:" | cut -d' ' -f2-)
if [ -n "$connected" ]; then
  echo "%{F#8CD0D3}BT%{F-} $connected"
else
  echo "%{F#F0DFAF}BT%{F-} on"
fi
