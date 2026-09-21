-- Plugin declarations. Each plugin's configuration lives in its own module
-- under lua/plugins/; keymaps live in lua/keymaps.lua.

-- local golisp filetype/syntax support, developed out of tree
vim.opt.rtp:prepend(vim.fn.expand("~/code/golisp-language/editors/neovim"))

vim.pack.add({
  { src = "https://github.com/leinonen/acidburn" },
  { src = "file:///home/leinonen/code/c64.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-mini/mini.icons" },
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
})

require("plugins.colorscheme")
require("plugins.snacks")
require("plugins.gitsigns")
require("plugins.oil")
require("plugins.icons")
require("plugins.dap")
require("plugins.markdown-preview")
