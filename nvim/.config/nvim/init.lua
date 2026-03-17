-- ============================================================
-- Options
-- ============================================================
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt
opt.number         = true
opt.relativenumber = true
opt.expandtab      = true
opt.shiftwidth     = 4
opt.tabstop        = 4
opt.smartindent    = true
opt.cursorline     = true
opt.scrolloff      = 8
opt.signcolumn     = "yes"   -- prevent layout shift on diagnostics
opt.updatetime     = 250     -- faster CursorHold / gitsigns

-- Defer clipboard to avoid slowing startup
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

vim.cmd.colorscheme("retrobox")

-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Plugins
-- ============================================================
require("lazy").setup({

  -- Icons (used by telescope, gitsigns, etc.)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Keybinding hints — press <leader> and wait
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = { delay = 500 },
  },

  -- Go development
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        dap_debug        = true,
        dap_debug_gui    = true,
        dap_debug_keymap = false, -- custom DAP keymaps defined below
        lsp_cfg          = false, -- LSP configured manually
        lsp_gofumpt      = true,
        lsp_on_attach    = false,
      })
    end,
    ft    = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      require("dap-go").setup()
      dapui.setup()

      -- Auto-open/close UI with debug session
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"]     = dapui.close

      -- DAP keymaps are global, not inside on_attach
      local map = vim.keymap.set
      map("n", "<F5>",       dap.continue,           { desc = "Debug: continue" })
      map("n", "<F10>",      dap.step_over,          { desc = "Debug: step over" })
      map("n", "<F11>",      dap.step_into,          { desc = "Debug: step into" })
      map("n", "<F12>",      dap.step_out,           { desc = "Debug: step out" })
      map("n", "<leader>db", dap.toggle_breakpoint,  { desc = "Toggle breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end,                                            { desc = "Conditional breakpoint" })
      map("n", "<leader>dr", dap.repl.open,          { desc = "Debug REPL" })
      map("n", "<leader>dt", require("dap-go").debug_test, { desc = "Debug test" })
      map("n", "<leader>du", dapui.toggle,           { desc = "Toggle DAP UI" })
    end,
  },

  -- Syntax / parsing
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "go", "gomod", "gowork", "gosum", "lua" },
        highlight        = { enable = true },
        indent           = { enable = true },
      })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>']     = cmp.mapping.abort(),
          ['<CR>']      = cmp.mapping.confirm({ select = false }),
          -- Tab handles both cmp navigation and snippet jumping
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Fuzzy finder (keymaps defined here so telescope loads lazily)
  {
    "nvim-telescope/telescope.nvim",
    tag          = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files()            end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep()             end, desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers()               end, desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags()             end, desc = "Help tags" },
      { "<leader>ld", function() require("telescope.builtin").lsp_definitions()       end, desc = "LSP definitions" },
      { "<leader>li", function() require("telescope.builtin").lsp_implementations()   end, desc = "LSP implementations" },
      { "<leader>lr", function() require("telescope.builtin").lsp_references()        end, desc = "LSP references" },
      { "<leader>ls", function() require("telescope.builtin").lsp_document_symbols()  end, desc = "Document symbols" },
      { "<leader>lw", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>lD", function() require("telescope.builtin").diagnostics()           end, desc = "All diagnostics" },
    },
  },

  -- Git decorations in the sign column
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },

}, {
  ui = { border = "rounded" },
})

-- ============================================================
-- Diagnostics
-- ============================================================
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    prefix  = "●",
    source  = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰌵 ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
  },
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

-- ============================================================
-- LSP
-- ============================================================
local on_attach = function(_, bufnr)
  local map  = vim.keymap.set
  local opts = { buffer = bufnr, silent = true }
  local ext  = function(desc) return vim.tbl_extend("force", opts, { desc = desc }) end

  -- Diagnostics
  map("n", "<leader>e", vim.diagnostic.open_float, ext("Show diagnostic"))
  map("n", "[d",        vim.diagnostic.goto_prev,  ext("Prev diagnostic"))
  map("n", "]d",        vim.diagnostic.goto_next,  ext("Next diagnostic"))
  map("n", "<leader>q", vim.diagnostic.setloclist, ext("Diagnostic list"))

  -- Navigation
  map("n", "gd",    vim.lsp.buf.definition,     ext("Definition"))
  map("n", "gi",    vim.lsp.buf.implementation, ext("Implementation"))
  map("n", "gr",    vim.lsp.buf.references,     ext("References"))
  map("n", "gD",    vim.lsp.buf.declaration,    ext("Declaration"))
  map("n", "K",     vim.lsp.buf.hover,          ext("Hover docs"))
  map("n", "<C-k>", vim.lsp.buf.signature_help, ext("Signature help"))

  -- Code actions
  map("n", "<leader>ca", vim.lsp.buf.code_action, ext("Code action"))
  map("n", "<leader>rn", vim.lsp.buf.rename,      ext("Rename"))
  map("n", "<leader>fm", function()
    vim.lsp.buf.format({ async = true })
  end, ext("Format"))
end

require("lspconfig").gopls.setup({
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach    = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow       = true,
      },
      staticcheck = true,
      gofumpt     = true,
      hints = {
        assignVariableTypes    = false,
        compositeLiteralFields = false,
        compositeLiteralTypes  = false,
        constantValues         = true,
        functionTypeParameters = false,
        parameterNames         = false,
        rangeVariableTypes     = false,
      },
    },
  },
})

-- ============================================================
-- Go keymaps
-- ============================================================
local map = vim.keymap.set

-- Tests
map("n", "<leader>tt", "<cmd>GoTestFunc<CR>",     { desc = "Test function" })
map("n", "<leader>tf", "<cmd>GoTestFile<CR>",     { desc = "Test file" })
map("n", "<leader>tp", "<cmd>GoTest<CR>",         { desc = "Test package" })
map("n", "<leader>tc", "<cmd>GoCoverage<CR>",     { desc = "Coverage" })
map("n", "<leader>tC", "<cmd>GoCoverageClear<CR>",{ desc = "Clear coverage" })

-- Code generation
map("n", "<leader>gj", "<cmd>GoAddTag json<CR>",  { desc = "Add JSON tags" })
map("n", "<leader>gy", "<cmd>GoAddTag yaml<CR>",  { desc = "Add YAML tags" })
map("n", "<leader>ge", "<cmd>GoIfErr<CR>",         { desc = "Add if err" })
map("n", "<leader>gf", "<cmd>GoFillStruct<CR>",    { desc = "Fill struct" })
map("n", "<leader>gr", "<cmd>GoRun<CR>",           { desc = "Run" })
map("n", "<leader>gb", "<cmd>GoBuild<CR>",         { desc = "Build" })

-- ============================================================
vim.o.winborder = "rounded"
