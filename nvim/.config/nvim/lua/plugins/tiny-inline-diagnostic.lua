-- Diagnostics shown inline at the cursor line, wrapped instead of truncated.
-- Built-in virtual_text is disabled in lua/lsp.lua.
require("tiny-inline-diagnostic").setup({
  preset = "modern",
  options = {
    show_source = { enabled = true },
    multilines = { enabled = true },
  },
})
