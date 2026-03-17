-- Set <Space> as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"

vim.cmd.colorscheme("retrobox")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        -- Enable debug support with delve
        dap_debug = true,
        dap_debug_gui = true,
        dap_debug_keymap = false, -- We'll set custom keymaps
        -- Disable go.nvim's LSP setup since we configure it manually
        lsp_cfg = false,
        lsp_gofumpt = true,
        lsp_on_attach = false,
      })
    end,
    ft = {"go", "gomod"},
    build = ':lua require("go.install").update_all_sync()',
  },
{
  "mfussenegger/nvim-dap",
  dependencies = {
    "leoluz/nvim-dap-go",        -- Go-specific config
    "rcarriga/nvim-dap-ui",      -- UI for debug panes
    "nvim-neotest/nvim-nio",     -- required by dap-ui
  },
  config = function()
    require("dap-go").setup()
    require("dapui").setup()

    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
  end,
},

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "go", "gomod", "gowork", "gosum" },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  { 
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
})

-- Configure diagnostics to show inline errors (NEW)
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    prefix = "●",
    source = "if_many",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Define diagnostic signs (NEW)
local signs = { 
  Error = " ", 
  Warn = " ", 
  Hint = "󰌵 ", 
  Info = " " 
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- nvim-cmp setup
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- LSP on_attach function with keybindings (NEW)
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  
  -- Diagnostics (Errors)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, 
    vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, 
    vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, 
    vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, 
    vim.tbl_extend("force", opts, { desc = "Diagnostic list" }))
  
  -- Navigation
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, 
    vim.tbl_extend("force", opts, { desc = "Go to definition" }))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, 
    vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
  vim.keymap.set("n", "gr", vim.lsp.buf.references, 
    vim.tbl_extend("force", opts, { desc = "Show references" }))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, 
    vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
  
  -- Show function definition/documentation
  vim.keymap.set("n", "K", vim.lsp.buf.hover, 
    vim.tbl_extend("force", opts, { desc = "Show documentation" }))
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, 
    vim.tbl_extend("force", opts, { desc = "Signature help" }))
  
  -- Debugging
local map = vim.keymap.set
map("n", "<F5>",  require("dap").continue)
map("n", "<F10>", require("dap").step_over)
map("n", "<F11>", require("dap").step_into)
map("n", "<F12>", require("dap").step_out)
map("n", "<leader>b",  require("dap").toggle_breakpoint)
map("n", "<leader>B",  function()
  require("dap").set_breakpoint(vim.fn.input("Condition: "))
end)
map("n", "<leader>dr", require("dap").repl.open)
map("n", "<leader>dt", require("dap-go").debug_test)  -- debug the test under cursor

  -- Code actions
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, 
    vim.tbl_extend("force", opts, { desc = "Code action" }))
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, 
    vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
  vim.keymap.set("n", "<leader>fm", function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", opts, { desc = "Format code" }))
end

-- LSP setup with enhanced configuration (UPDATED)
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = true,
      hints = {
        assignVariableTypes = false,
        compositeLiteralFields = false,
        compositeLiteralTypes = false,
        constantValues = true,
        functionTypeParameters = false,
        parameterNames = false,
        rangeVariableTypes = false,
      },
    },
  },
})

-- Telescope keybindings (EXISTING + NEW)
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })

-- LSP-related telescope keybindings (NEW)
vim.keymap.set('n', '<leader>ld', builtin.lsp_definitions, { desc = "LSP definitions" })
vim.keymap.set('n', '<leader>li', builtin.lsp_implementations, { desc = "LSP implementations" })
vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { desc = "LSP references" })
vim.keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set('n', '<leader>lw', builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
vim.keymap.set('n', '<leader>lD', builtin.diagnostics, { desc = "All diagnostics" })

-- Go-specific keybindings (EXISTING + NEW)
-- Tests
vim.keymap.set('n', '<leader>tt', ':GoTestFunc<CR>', { desc = "Go test function" })
vim.keymap.set('n', '<leader>tf', ':GoTestFile<CR>', { desc = "Go test file" })
vim.keymap.set('n', '<leader>tp', ':GoTest<CR>', { desc = "Go test package" })
vim.keymap.set('n', '<leader>tc', ':GoCoverage<CR>', { desc = "Go coverage" })
vim.keymap.set('n', '<leader>tC', ':GoCoverageClear<CR>', { desc = "Clear coverage" })

-- Code generation (NEW)
vim.keymap.set('n', '<leader>gj', ':GoAddTag json<CR>', { desc = "Add JSON tags" })
vim.keymap.set('n', '<leader>gy', ':GoAddTag yaml<CR>', { desc = "Add YAML tags" })
vim.keymap.set('n', '<leader>ge', ':GoIfErr<CR>', { desc = "Add if err" })
vim.keymap.set('n', '<leader>gf', ':GoFillStruct<CR>', { desc = "Fill struct" })

-- Build and run (NEW)
vim.keymap.set('n', '<leader>gr', ':GoRun<CR>', { desc = "Go run" })
vim.keymap.set('n', '<leader>gb', ':GoBuild<CR>', { desc = "Go build" })

-- Debug keybindings with Delve (NEW)
vim.keymap.set('n', '<leader>db', ':GoBreakToggle<CR>', { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<leader>dd', ':GoDebug<CR>', { desc = "Start debug" })
vim.keymap.set('n', '<leader>ds', ':GoDebug -s<CR>', { desc = "Stop debug" })
vim.keymap.set('n', '<leader>dc', ':GoDbgContinue<CR>', { desc = "Debug continue" })
vim.keymap.set('n', '<leader>dn', ':GoDbgStep<CR>', { desc = "Debug step over" })
vim.keymap.set('n', '<leader>di', ':GoDbgStepIn<CR>', { desc = "Debug step in" })
vim.keymap.set('n', '<leader>do', ':GoDbgStepOut<CR>', { desc = "Debug step out" })

vim.o.winborder = "rounded"
