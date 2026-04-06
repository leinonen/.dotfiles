-- init.lua — minimal Go dev
vim.g.mapleader = " "

local o = vim.opt
o.number         = true
o.relativenumber = true
o.signcolumn     = "yes"
o.cursorline     = true
o.tabstop        = 4
o.shiftwidth     = 4
o.expandtab      = false  -- Go uses real tabs
o.termguicolors  = true
o.completeopt    = { "menu", "menuone", "noselect" }

vim.cmd.colorscheme("retrobox")

require("statusline").setup()

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" } },
  { "mfussenegger/nvim-dap" },
})

require("telescope").setup({
  pickers = {
    colorscheme = {
      enable_preview = true,
    },
  },
})

-- Built-in LSP (Neovim 0.11+)
vim.lsp.config("gopls", {
  cmd       = { "gopls" },
  filetypes = { "go", "gomod", "gowork" },
  settings  = { gopls = { gofumpt = true, staticcheck = true } },
})
vim.lsp.enable("gopls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local b = vim.lsp.buf
    local m = function(k, f) vim.keymap.set("n", k, f, { buffer = ev.buf }) end
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    vim.keymap.set("i", "<C-Space>", function() vim.lsp.completion.trigger() end, { buffer = ev.buf })
    vim.keymap.set("i", "<C-e>",     "<C-x><C-z>",               { buffer = ev.buf })
    m("gd",         b.definition)
    m("K",          b.hover)
    m("<leader>rn", b.rename)
    m("<leader>ca", b.code_action)
    m("<leader>f",  function() b.format({ async = true }) end)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    vim.lsp.buf.format({ async = false })
  end,
})

-- DAP / Delve
local dap = require("dap")

dap.adapters.go = {
  type = "server",
  port = "${port}",
  executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}

dap.configurations.go = {
  { type = "go", name = "Debug",            request = "launch", program = "${file}" },
  { type = "go", name = "Debug package",    request = "launch", program = "${fileDirname}" },
  { type = "go", name = "Debug test",       request = "launch", program = "${file}", mode = "test" },
  { type = "go", name = "Attach",           request = "attach", processId = require("dap.utils").pick_process },
}

local m = function(k, f, d) vim.keymap.set("n", k, f, { desc = d }) end
m("<F5>",        dap.continue,          "Debug: continue")
m("<F10>",       dap.step_over,         "Debug: step over")
m("<F11>",       dap.step_into,         "Debug: step into")
m("<F12>",       dap.step_out,          "Debug: step out")
m("<leader>db",  dap.toggle_breakpoint, "Debug: toggle breakpoint")
m("<leader>dr",  dap.repl.open,         "Debug: open REPL")

-- Go run / test
local function term(cmd)
  vim.cmd("split | terminal " .. cmd)
end
 
vim.keymap.set("n", "<leader>tr", function() term("go run ./...") end,          { desc = "go run" })
vim.keymap.set("n", "<leader>tt", function() term("go test ./...") end,         { desc = "go test" })
vim.keymap.set("n", "<leader>tv", function() term("go test -v ./...") end,      { desc = "go test -v" })
vim.keymap.set("n", "<leader>tc", function() term("go test -cover ./...") end,  { desc = "go test -cover" })
vim.keymap.set("n", "<leader>tl", function() term("go test -run " .. vim.fn.expand("<cword>") .. " ./...") end, { desc = "go test func under cursor" })

-- Telescope
local t = require("telescope.builtin")

-- files
vim.keymap.set("n", "<leader><leader>", t.find_files)
vim.keymap.set("n", "<leader>/",        t.live_grep)
vim.keymap.set("n", "<leader>b",        t.buffers)

-- lsp
vim.keymap.set("n", "<leader>d",  t.diagnostics)
vim.keymap.set("n", "<leader>s",  t.lsp_document_symbols)
vim.keymap.set("n", "<leader>S",  t.lsp_workspace_symbols)
vim.keymap.set("n", "gr",         t.lsp_references)
vim.keymap.set("n", "gi",         t.lsp_implementations)
