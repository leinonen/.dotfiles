# .dotfiles

## tmux
```sh
stow tmux
```

## neovim
```sh
stow -t ~ nvim
```

## Sway desktop (sway, waybar, kanshi, bin)

Ubuntu 26.04 on an Intel + NVIDIA laptop. Replaced the old i3/polybar/picom/autorandr setup (now in `archive/i3-x11`).

| Package | What |
|---|---|
| `sway` | sway config, plus `sway-intel.desktop`, the GDM session file |
| `waybar` | bar (polybar port) and its battery/bluetooth/wifi scripts |
| `kanshi` | monitor profiles: laptop only, or external only with the panel off |
| `bin` | `sway-session` (launcher), `c64lock-sway` (lock), `mon-sway` (Mod+Shift+p toggle) |

### Install

```sh
sudo apt install sway swaybg swayidle swaylock waybar kanshi grim slurp wl-clipboard \
    jq rofi foot dex network-manager-gnome blueman pavucontrol

cd ~/.dotfiles
stow -t ~ sway waybar kanshi bin

# login entry that starts sway on the Intel GPU only
sudo cp sway/.config/sway/sway-intel.desktop /usr/share/wayland-sessions/
# hide the plain "Sway" entry, which can't start while the nvidia module is loaded
sudo sh -c 'echo "Hidden=true" >> /usr/share/wayland-sessions/sway.desktop'

sway -C   # validate config
```

Log out, click the gear on the GDM password screen, pick **Sway (Intel)**.

`sway-intel.desktop` hardcodes `/home/leinonen/.local/bin/sway-session`. Change the path if your username differs.

### Not in this repo

- `~/.local/share/wallpapers/c64lock.py`: generates the C64 lock image (needs `python3-pil`)
- C64 font under `~/.local/share/fonts/c64/`, and ShureTechMono Nerd Font for waybar

### Gotchas

- **NVIDIA:** sway won't start while the proprietary `nvidia` module is loaded. `sway-session` passes `--unsupported-gpu` and sets `WLR_DRM_DEVICES` to the Intel card. All outputs (eDP-1, DP-1..4) are wired to Intel, so NVIDIA isn't needed for display.
- **Stuck on the Ubuntu logo / sway "Permission denied" on /dev/dri:** a udev `RUN+=` script hung and blocked udev. Don't add udev hotplug scripts; kanshi handles monitors. Remove any leftover `/etc/udev/rules.d/95-autorandr.rules`.
- **kanshi:** Ubuntu's package has no `kanshictl`. Sway restarts kanshi on every reload instead.
- **Outputs wrong?** `swaymsg -t get_outputs` shows names; edit `kanshi/.config/kanshi/config`.
- **No bar?** Run `waybar` in a terminal to see errors.
