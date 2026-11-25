-- All global keymaps live here. Buffer-local ones stay with what creates them
-- (LSP -> lua/lsp.lua, gitsigns -> lua/plugins/gitsigns.lua).
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- completion keymaps live in lua/plugins/blink.lua

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

-- go docs (godoc.nvim, snacks picker)
map("n", "<leader>gd", "<CMD>GoDoc<CR>", "Go docs")

-- go: toggle between foo.go and foo_test.go (only if the other file exists)
map("n", "<leader>gt", function()
  if vim.bo.filetype ~= "go" then return end
  local file = vim.api.nvim_buf_get_name(0)
  local alt = file:match("_test%.go$") and file:gsub("_test%.go$", ".go")
    or file:gsub("%.go$", "_test.go")
  if vim.uv.fs_stat(alt) then
    vim.cmd.edit(vim.fn.fnameescape(alt))
  else
    vim.notify("No file: " .. vim.fn.fnamemodify(alt, ":~:."), vim.log.levels.WARN)
  end
end, "Go: toggle test file")

-- go: run tests/build in a split terminal
local term = function(cmd)
  return function() vim.cmd("split | terminal " .. cmd) end
end

map("n", "<leader>tr", term("go run ./..."),         "go run")
map("n", "<leader>tl", term("go test ./..."),        "go test")
map("n", "<leader>tv", term("go test -v ./..."),     "go test -v")
map("n", "<leader>tc", term("go test -cover ./..."), "go test -cover")

-- name of the Test/Benchmark/Fuzz/Example func enclosing the cursor
local go_test_name = function()
  -- go buffers don't run treesitter highlighting, so parse on demand
  vim.treesitter.get_parser(0, "go"):parse()
  local node = vim.treesitter.get_node({ lang = "go" })
  while node do
    if node:type() == "function_declaration" then
      local name = vim.treesitter.get_node_text(node:field("name")[1], 0)
      if name:match("^Test") or name:match("^Benchmark")
        or name:match("^Fuzz") or name:match("^Example") then
        return name
      end
    end
    node = node:parent()
  end
end

-- run only that test, in the file's package, in a floating snacks terminal
map("n", "<leader>tt", function()
  if vim.bo.filetype ~= "go" then return end
  local name = go_test_name()
  if not name then
    return vim.notify("Cursor is not inside a test function", vim.log.levels.WARN)
  end
  local pat = "^" .. name .. "$"
  local cmd = name:match("^Benchmark")
    and { "go", "test", "-v", "-run", "^$", "-bench", pat, "." }
    or { "go", "test", "-v", "-run", pat, "." }
  Snacks.terminal.open(cmd, {
    cwd = vim.fn.expand("%:p:h"),
    interactive = false, -- keep output open; q closes
    win = { position = "float" },
  })
end, "go test func under cursor (float)")

-- debugger (nvim-dap)
-- local dap = function(name)
--   return function() require("dap")[name]() end
-- end
--
-- map("n", "<F5>",       dap("continue"),          "Debug: continue")
-- map("n", "<F10>",      dap("step_over"),         "Debug: step over")
-- map("n", "<F11>",      dap("step_into"),         "Debug: step into")
-- map("n", "<F12>",      dap("step_out"),          "Debug: step out")
-- map("n", "<leader>db", dap("toggle_breakpoint"), "Debug: toggle breakpoint")
-- map("n", "<leader>dr", function() require("dap").repl.open() end, "Debug: open REPL")

-- markdown
map("n", "<leader>mp", "<Plug>MarkdownPreviewToggle", "Toggle Markdown preview")

-- disable macro recording
map("n", "q", "<Nop>")

