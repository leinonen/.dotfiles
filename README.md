# .dotfiles

## vim
```sh
sh scripts/install_vim_plug.sh
stow vim
```

## tmux
```sh
stow tmux
```

## neovim
```sh
stow -t ~ nvim
nvim --headless "+Lazy! sync" +qa
```

### Neovim requirements
- Neovim 0.11+
- `git`, `go`, `gopls`, `gofumpt`
