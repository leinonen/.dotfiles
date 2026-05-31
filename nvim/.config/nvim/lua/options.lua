local o = vim.opt
o.number         = true
o.relativenumber = true
o.scrolloff      = 10
o.sidescrolloff  = 10
o.signcolumn     = "yes"
o.cursorline     = true
o.tabstop        = 4
o.shiftwidth     = 4
o.expandtab      = false  -- Go uses real tabs
o.termguicolors  = true
o.completeopt    = { "menu", "menuone", "noselect" }
o.clipboard      = "unnamedplus"
o.background     = "dark"
o.winborder      = "rounded"
vim.cmd.colorscheme("default")

vim.opt.wrap      = false
vim.opt.linebreak = false
