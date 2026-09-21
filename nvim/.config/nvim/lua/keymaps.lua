-- All global keymaps live here. Buffer-local ones stay with what creates them
-- (LSP -> lua/lsp.lua, gitsigns -> lua/plugins/gitsigns.lua).
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- completion menu: Tab/S-Tab cycle, Enter accepts selected item
local pum = function(yes, no)
  return function() return vim.fn.pumvisible() == 1 and yes or no end
end
vim.keymap.set("i", "<Tab>",   pum("<C-n>", "<Tab>"),   { expr = true })
vim.keymap.set("i", "<S-Tab>", pum("<C-p>", "<S-Tab>"), { expr = true })
vim.keymap.set("i", "<CR>", function()
  return vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<CR>"
end, { expr = true })

-- files
map("n", "-", "<CMD>Oil<CR>", "Open parent directory")

-- picker (snacks); resolved lazily so load order can't break these
local pick = function(name, ...)
  local args = { ... }
  return function() Snacks.picker[name](unpack(args)) end
end

map("n", "<leader><leader>", pick("files"),                  "Find files")
map("n", "<leader>/",        pick("grep"),                   "Grep")
map("n", "<leader>b",        pick("buffers"),                "Buffers")
map("n", "<leader>d",        pick("diagnostics"),            "Diagnostics")
map("n", "<leader>s",        pick("lsp_symbols"),            "Document symbols")
map("n", "<leader>S",        pick("lsp_workspace_symbols"),  "Workspace symbols")
map("n", "gr",               pick("lsp_references"),         "References")
map("n", "gi",               pick("lsp_implementations"),    "Implementations")

-- zen mode (snacks); Snacks resolved lazily like the pickers above
map("n", "<leader>z", function() Snacks.zen() end,      "Toggle zen mode")
map("n", "<leader>Z", function() Snacks.zen.zoom() end, "Toggle zoom")

-- go: run tests/build in a split terminal
local term = function(cmd)
  return function() vim.cmd("split | terminal " .. cmd) end
end

map("n", "<leader>tr", term("go run ./..."),         "go run")
map("n", "<leader>tt", term("go test ./..."),        "go test")
map("n", "<leader>tv", term("go test -v ./..."),     "go test -v")
map("n", "<leader>tc", term("go test -cover ./..."), "go test -cover")
map("n", "<leader>tl", function()
  term("go test -run " .. vim.fn.expand("<cword>") .. " ./...")()
end, "go test func under cursor")

-- debugger (nvim-dap)
local dap = function(name)
  return function() require("dap")[name]() end
end

map("n", "<F5>",       dap("continue"),          "Debug: continue")
map("n", "<F10>",      dap("step_over"),         "Debug: step over")
map("n", "<F11>",      dap("step_into"),         "Debug: step into")
map("n", "<F12>",      dap("step_out"),          "Debug: step out")
map("n", "<leader>db", dap("toggle_breakpoint"), "Debug: toggle breakpoint")
map("n", "<leader>dr", function() require("dap").repl.open() end, "Debug: open REPL")

-- markdown
map("n", "<leader>mp", "<Plug>MarkdownPreviewToggle", "Toggle Markdown preview")
