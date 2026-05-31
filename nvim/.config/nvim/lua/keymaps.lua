vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local function term(cmd)
  vim.cmd("split | terminal " .. cmd)
end

vim.keymap.set("n", "<leader>tr", function() term("go run ./...") end,         { desc = "go run" })
vim.keymap.set("n", "<leader>tt", function() term("go test ./...") end,        { desc = "go test" })
vim.keymap.set("n", "<leader>tv", function() term("go test -v ./...") end,     { desc = "go test -v" })
vim.keymap.set("n", "<leader>tc", function() term("go test -cover ./...") end, { desc = "go test -cover" })
vim.keymap.set("n", "<leader>tl", function()
  term("go test -run " .. vim.fn.expand("<cword>") .. " ./...")
end, { desc = "go test func under cursor" })

local pick  = require("mini.pick")
local extra = require("mini.extra")

vim.keymap.set("n", "<leader><leader>", function() pick.builtin.files() end)
vim.keymap.set("n", "<leader>/",        function() pick.builtin.grep_live() end)
vim.keymap.set("n", "<leader>b",        function() pick.builtin.buffers() end)

vim.keymap.set("n", "<leader>d", function() extra.pickers.diagnostic() end)
vim.keymap.set("n", "<leader>s", function() extra.pickers.lsp({ scope = "document_symbol" }) end)
vim.keymap.set("n", "<leader>S", function() extra.pickers.lsp({ scope = "workspace_symbol" }) end)
vim.keymap.set("n", "gr",        function() extra.pickers.lsp({ scope = "references" }) end)
vim.keymap.set("n", "gi",        function() extra.pickers.lsp({ scope = "implementation" }) end)
