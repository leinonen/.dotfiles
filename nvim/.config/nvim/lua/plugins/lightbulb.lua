-- Sign-column lightbulb on lines with available LSP code actions
-- (<leader>ca to run them).
require("nvim-lightbulb").setup({
  autocmd = {
    enabled = true,
    updatetime = -1, -- keep updatetime from lua/options.lua
  },
})
