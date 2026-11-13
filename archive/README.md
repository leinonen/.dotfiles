# archive

Retired configs, kept for reference. Not stowed.

## i3-x11

The i3 / polybar / picom / autorandr setup used before moving to sway
(Ubuntu 26.04, 2026-11). Paths mirror `$HOME`. To restore:

```sh
sudo apt install i3 polybar picom feh xss-lock i3lock autorandr xorg xserver-xorg-input-libinput
stow -d ~/.dotfiles/archive -t ~ i3-x11
```

Don't bring back a udev `RUN+=` hotplug script for autorandr: one hung at
boot and blocked GPU access. Use autorandr's own packaged udev hook instead.
