# .dotfiles

## tmux
```sh
stow tmux
```

## neovim
```sh
stow -t ~ nvim
```


## sway
```sh
stow -t ~ sway
sudo cp sway/.config/sway/sway-intel.desktop /usr/share/wayland-sessions/
```

## waybar
```sh
stow -t ~ waybar
```

## kanshi
```sh
stow -t ~ kanshi
```

## bin
Sway helper scripts (session launcher, lock screen, monitor toggle).
`c64lock-sway` needs `~/.local/share/wallpapers/c64lock.py` and the C64 font.
```sh
stow -t ~ bin
```
