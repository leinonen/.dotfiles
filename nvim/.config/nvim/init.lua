-- Entry point. Load order matters: options -> plugins -> lsp -> keymaps.
vim.g.mapleader = " "

require("options")
require("autocmds")
require("statusline").setup()
require("plugins")
require("lsp")
require("keymaps")
