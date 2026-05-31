vim.opt.shortmess:append("I")
vim.g.mapleader = " "

require("options")
require("autocmds")
require("statusline").setup()
require("plugins")
require("lsp")
require("dap_config")
require("keymaps")
