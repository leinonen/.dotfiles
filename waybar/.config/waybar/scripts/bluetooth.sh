#!/usr/bin/env bash
# Waybar bluetooth status: shows power state + connected device name.
# Left-click (configured in config.jsonc) opens blueman-manager.

if ! bluetoothctl show | grep -q "Powered: yes"; then
  echo "<span color='#7F7F7F'>BT off</span>"
  exit 0
fi

connected=$(bluetoothctl info 2>/dev/null | grep -m1 "Name:" | cut -d' ' -f2-)
# escape for pango markup (quoted replacements: bash 5.2 treats bare & as the match)
connected=${connected//&/'&amp;'}; connected=${connected//</'&lt;'}
if [ -n "$connected" ]; then
  echo "<span color='#8CD0D3'>BT</span> $connected"
else
  echo "<span color='#F0DFAF'>BT</span> on"
fi
