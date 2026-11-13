#!/usr/bin/env bash
# Battery module for waybar (ported from polybar). Replaces internal/battery, which can't show its
# low state while on AC. Below LOW_AT the whole module is red, plugged in or not.

BAT=/sys/class/power_supply/BAT0
AC=/sys/class/power_supply/AC
LOW_AT=10
FULL_AT=99
PRIMARY=${PRIMARY:-#9dff4d}
ALERT=${ALERT:-#ff4d4d}

# Font Awesome battery icons, empty to full (U+F244..U+F240).
icons=($'\xef\x89\x84' $'\xef\x89\x83' $'\xef\x89\x82' $'\xef\x89\x81' $'\xef\x89\x80')

tick=0
while :; do
  # Each tick is 0.5s; read sysfs every 5s.
  if ((tick % 10 == 0)); then
    read -r capacity <"$BAT/capacity"
    read -r online <"$AC/online"

    # Notify once per low-battery episode; re-arm on AC or once back above LOW_AT.
    if ((capacity < LOW_AT && online != 1)); then
      if ((!notified)); then
        notify-send -u critical "Battery low" "$capacity% remaining. Plug in charger." >/dev/null 2>&1 &
        notified=1
      fi
    else
      notified=0
    fi
  fi

  ramp=$((capacity * 5 / 100))
  ((ramp > 4)) && ramp=4

  if ((capacity >= FULL_AT)); then
    icon=${icons[4]}
  elif ((online == 1)); then
    icon=${icons[tick % 5]}
  elif ((capacity < LOW_AT)); then
    icon=${icons[(tick % 2) * 4]}
  else
    icon=${icons[ramp]}
  fi

  if ((capacity < LOW_AT)); then
    echo "<span color='$ALERT'>BAT $icon $capacity%</span>"
  else
    echo "<span color='$PRIMARY'>BAT $icon</span> $capacity%"
  fi

  tick=$((tick + 1))
  sleep 0.5
done
