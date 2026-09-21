local o = vim.opt

o.shortmess:append("I") -- no intro message

-- ui
o.number         = true
o.relativenumber = true
o.scrolloff      = 10
o.sidescrolloff  = 10
o.signcolumn     = "yes"
o.cursorline     = true
o.colorcolumn    = "80,100,120"
o.termguicolors  = true
o.background     = "dark"
o.winborder      = "rounded"

-- indent
o.tabstop    = 4
o.shiftwidth = 4
o.expandtab  = false -- Go uses real tabs

-- editing
o.wrap       = false
o.linebreak  = false
o.ignorecase = true
o.smartcase  = true
o.clipboard  = "unnamedplus"
o.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
