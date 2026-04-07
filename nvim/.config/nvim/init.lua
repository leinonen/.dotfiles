-- init.lua — minimal Go dev
vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = false -- Go uses real tabs
o.termguicolors = true
o.completeopt = { "menu", "menuone", "noselect" }

vim.cmd.colorscheme("retrobox")

require("statusline").setup()

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope.nvim" },
  { src = "https://github.com/mfussenegger/nvim-dap", name = "nvim-dap" },
}, { load = false, confirm = false })

local loaded_plugins = {}

local function load_plugin(name)
  if loaded_plugins[name] then
    return
  end

  vim.cmd.packadd(name)
  loaded_plugins[name] = true
end

local function with_plugin(name, callback)
  return function(...)
    load_plugin(name)
    return callback(...)
  end
end

local telescope_ready = false

local function ensure_telescope()
  load_plugin("telescope.nvim")

  if telescope_ready then
    return
  end

  require("telescope").setup({
    pickers = {
      colorscheme = {
        enable_preview = true,
      },
    },
  })

  telescope_ready = true
end

local function telescope_builtin(name)
  return with_plugin("telescope.nvim", function()
    ensure_telescope()
    require("telescope.builtin")[name]()
  end)
end

-- Built-in LSP (Neovim 0.11+)
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork" },
  settings = { gopls = { gofumpt = true, staticcheck = true } },
})
vim.lsp.enable("gopls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local b = vim.lsp.buf
    local m = function(k, f) vim.keymap.set("n", k, f, { buffer = ev.buf }) end
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    vim.keymap.set("i", "<C-Space>", function() vim.lsp.completion.trigger() end, { buffer = ev.buf })
    vim.keymap.set("i", "<C-e>", "<C-x><C-z>", { buffer = ev.buf })
    m("gd", b.definition)
    m("K", b.hover)
    m("<leader>rn", b.rename)
    m("<leader>ca", b.code_action)
    m("<leader>f", function() b.format({ async = true }) end)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    vim.lsp.buf.format({ async = false })
  end,
})

local dap_ready = false

local function ensure_dap()
  load_plugin("nvim-dap")

  if dap_ready then
    return require("dap")
  end

  local dap = require("dap")

  dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
  }

  dap.configurations.go = {
    { type = "go", name = "Debug", request = "launch", program = "${file}" },
    { type = "go", name = "Debug package", request = "launch", program = "${fileDirname}" },
    { type = "go", name = "Debug test", request = "launch", program = "${file}", mode = "test" },
    { type = "go", name = "Attach", request = "attach", processId = require("dap.utils").pick_process },
  }

  dap_ready = true

  return dap
end

local map = function(k, f, d) vim.keymap.set("n", k, f, { desc = d }) end
map("<F5>", with_plugin("nvim-dap", function() ensure_dap().continue() end), "Debug: continue")
map("<F10>", with_plugin("nvim-dap", function() ensure_dap().step_over() end), "Debug: step over")
map("<F11>", with_plugin("nvim-dap", function() ensure_dap().step_into() end), "Debug: step into")
map("<F12>", with_plugin("nvim-dap", function() ensure_dap().step_out() end), "Debug: step out")
map("<leader>db", with_plugin("nvim-dap", function() ensure_dap().toggle_breakpoint() end), "Debug: toggle breakpoint")
map("<leader>dr", with_plugin("nvim-dap", function() ensure_dap().repl.open() end), "Debug: open REPL")

-- Go run / test
local function term(cmd)
  vim.cmd("split | terminal " .. cmd)
end

vim.keymap.set("n", "<leader>tr", function() term("go run ./...") end, { desc = "go run" })
vim.keymap.set("n", "<leader>tt", function() term("go test ./...") end, { desc = "go test" })
vim.keymap.set("n", "<leader>tv", function() term("go test -v ./...") end, { desc = "go test -v" })
vim.keymap.set("n", "<leader>tc", function() term("go test -cover ./...") end, { desc = "go test -cover" })
vim.keymap.set("n", "<leader>tl", function() term("go test -run " .. vim.fn.expand("<cword>") .. " ./...") end, { desc = "go test func under cursor" })

-- Telescope
vim.keymap.set("n", "<leader><leader>", telescope_builtin("find_files"))
vim.keymap.set("n", "<leader>/", telescope_builtin("live_grep"))
vim.keymap.set("n", "<leader>b", telescope_builtin("buffers"))

-- lsp
vim.keymap.set("n", "<leader>d", telescope_builtin("diagnostics"))
vim.keymap.set("n", "<leader>s", telescope_builtin("lsp_document_symbols"))
vim.keymap.set("n", "<leader>S", telescope_builtin("lsp_workspace_symbols"))
vim.keymap.set("n", "gr", telescope_builtin("lsp_references"))
vim.keymap.set("n", "gi", telescope_builtin("lsp_implementations"))
