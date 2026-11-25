-- Completion. Replaces native vim.lsp.completion; LSP capabilities are
-- registered automatically by blink on nvim 0.11+.
require("blink.cmp").setup({
  -- mirror the old pum mappings: Tab/S-Tab cycle, Enter accepts selection
  keymap = {
    preset = "none",
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"]     = { "hide", "fallback" },
    ["<CR>"]      = { "accept", "fallback" },
    ["<Tab>"]     = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },
    ["<C-n>"]     = { "select_next", "fallback" },
    ["<C-p>"]     = { "select_prev", "fallback" },
    ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
    ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
  },
  completion = {
    list = { selection = { preselect = false, auto_insert = true } },
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  signature = { enabled = true },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  -- prebuilt rust matcher is fetched for tagged releases; lua fallback otherwise
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
