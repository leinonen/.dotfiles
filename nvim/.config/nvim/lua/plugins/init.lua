-- Plugin declarations. Each plugin's configuration lives in its own module
-- under lua/plugins/; keymaps live in lua/keymaps.lua.

-- local golisp filetype/syntax support, developed out of tree
vim.opt.rtp:prepend(vim.fn.expand("~/code/golisp-language/editors/neovim"))

vim.env.GIT_CONFIG_COUNT = "1"
vim.env.GIT_CONFIG_KEY_0 = "url.https://pkg.leinonen.ninja/git/github.com/.insteadOf"
vim.env.GIT_CONFIG_VALUE_0 = "https://github.com/"

vim.pack.add({
  { src = "https://github.com/leinonen/acidburn" },
  { src = "file:///home/leinonen/code/c64.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-mini/mini.icons" },
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  { src = "https://github.com/maxandron/goplements.nvim" },
  -- { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
  -- svelte syntax; vim-svelte needs html5.vim and vim-javascript
  { src = "https://github.com/othree/html5.vim" },
  { src = "https://github.com/pangloss/vim-javascript" },
  { src = "https://github.com/evanleck/vim-svelte" },
})

require("plugins.colorscheme")
require("plugins.snacks")
require("plugins.gitsigns")
require("plugins.oil")
require("plugins.icons")
require("plugins.blink")
require("plugins.goplements")
-- require("plugins.dap")
require("plugins.markdown-preview")
