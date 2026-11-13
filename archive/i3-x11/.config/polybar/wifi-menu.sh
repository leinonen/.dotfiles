#!/usr/bin/env bash
# rofi-based wifi network selector for polybar wlan module

# kick off a rescan in the background so the next open is fresh, but don't wait on it
nmcli device wifi rescan >/dev/null 2>&1 &

# show cached results immediately (no blocking scan)
list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no \
  | awk -F: 'NF && $2!="" {
        sec    = ($4=="") ? "open" : $4;
        active = ($1=="*") ? "  *" : "";
        printf "%s  (%s%%, %s)%s\n", $2, $3, sec, active
    }' | sort -u)

[ -z "$list" ] && { rofi -e "No Wi-Fi networks found"; exit 0; }

choice=$(printf '%s\n' "$list" | rofi -dmenu -i -p "Wi-Fi")
[ -z "$choice" ] && exit 0

# recover SSID: strip trailing "  (45%, WPA2)" and any active "  *" marker
ssid=$(printf '%s' "$choice" | sed -E 's/  \([0-9]+%, [^)]*\)( *\*)?$//')
[ -z "$ssid" ] && exit 0

# already a saved connection? just bring it up
if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid"
    exit $?
fi

# determine security for this SSID
sec=$(nmcli -t -f SSID,SECURITY device wifi list | awk -F: -v s="$ssid" '$1==s{print $2; exit}')

if [ -n "$sec" ]; then
    pass=$(rofi -dmenu -p "Password for $ssid" -password </dev/null)
    [ -z "$pass" ] && exit 0
    nmcli device wifi connect "$ssid" password "$pass"
else
    nmcli device wifi connect "$ssid"
fi
