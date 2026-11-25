-- :GoDoc [pkg[.Symbol]] -- browse `go doc` output via the snacks picker.
-- Highlighting needs the godoc + go treesitter parsers (bin/nvim-ts-parser):
--   nvim-ts-parser go v0.25.0
--   TS_REPO=https://github.com/fredrikaverpil/tree-sitter-godoc nvim-ts-parser godoc v0.1.0
require("godoc").setup({
  adapters = {
    {
      name = "go",
      opts = {
        get_syntax_info = function()
          return { filetype = "godoc", language = "godoc" }
        end,
      },
    },
  },
  picker = { type = "snacks" },
})

-- godoc.nvim only registers the parser; start highlighting ourselves
vim.api.nvim_create_autocmd("FileType", {
  pattern = "godoc",
  callback = function(ev) vim.treesitter.start(ev.buf) end,
})
