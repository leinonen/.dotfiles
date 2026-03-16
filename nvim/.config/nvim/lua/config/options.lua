vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.undofile = true
opt.expandtab = false
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.scrolloff = 6
opt.sidescrolloff = 6
