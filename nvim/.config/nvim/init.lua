-- Neovim 0.11+ single-file config focused on Go development

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.updatetime = 200
opt.timeoutlen = 350
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.undofile = true
opt.expandtab = false
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.scrolloff = 6
opt.sidescrolloff = 6

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded' },
})

local core_group = vim.api.nvim_create_augroup('dotfiles_core', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = core_group,
  desc = 'Highlight yanked text',
  callback = function()
    vim.highlight.on_yank({ timeout = 180 })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = core_group,
  pattern = { 'go', 'gomod', 'gowork', 'gotmpl' },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

local seen_global_maps = {}
local function map(mode, lhs, rhs, desc)
  local key = table.concat(type(mode) == 'table' and mode or { mode }, ',') .. '::' .. lhs
  if seen_global_maps[key] then
    error(('Duplicate global keymap: %s (%s vs %s)'):format(key, seen_global_maps[key], desc or 'no description'))
  end
  seen_global_maps[key] = desc or 'no description'
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

map('n', '<leader>w', '<cmd>write<cr>', 'Write buffer')
map('n', '<leader>q', '<cmd>quit<cr>', 'Quit window')
map('n', '<leader>h', '<cmd>nohlsearch<cr>', 'Clear search highlight')

map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', 'Find files')
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', 'Live grep')
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', 'Find buffers')
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', 'Help tags')

map('n', '<leader>e', vim.diagnostic.open_float, 'Line diagnostics')
map('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')

-- Go actions (kept on <leader>g* to avoid clashing with LSP's g* motions)
map('n', '<leader>gr', '<cmd>GoRun<cr>', 'Go run')
map('n', '<leader>gt', '<cmd>GoTest<cr>', 'Go test package')
map('n', '<leader>gT', '<cmd>GoTestFunc<cr>', 'Go test function')
map('n', '<leader>gi', '<cmd>GoImpl<cr>', 'Go implement interface')
map('n', '<leader>gf', '<cmd>GoFmt<cr>', 'Go format file')

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'protesilaos/ef-themes.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme('ef-dream')
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      defaults = {
        layout_strategy = 'horizontal',
        sorting_strategy = 'ascending',
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'go',
          'gomod',
          'gowork',
          'gosum',
          'lua',
          'vim',
          'vimdoc',
          'bash',
          'json',
          'yaml',
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  {
    'williamboman/mason.nvim',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = { 'gopls', 'lua_ls' },
      automatic_installation = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('dotfiles_lsp', { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local seen_buf_maps = {}
          local function bmap(lhs, rhs, desc)
            if seen_buf_maps[lhs] then
              error(('Duplicate LSP buffer keymap: %s (%s vs %s)'):format(lhs, seen_buf_maps[lhs], desc or 'no description'))
            end
            seen_buf_maps[lhs] = desc or 'no description'
            vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          bmap('gd', vim.lsp.buf.definition, 'Go to definition')
          bmap('gD', vim.lsp.buf.declaration, 'Go to declaration')
          bmap('gi', vim.lsp.buf.implementation, 'Go to implementation')
          bmap('gr', vim.lsp.buf.references, 'Find references')
          bmap('K', vim.lsp.buf.hover, 'Hover docs')
          bmap('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
          bmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')

          if vim.lsp.inlay_hint then
            pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
          end
        end,
      })

      local lspconfig = require('lspconfig')

      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          },
        },
      })

      lspconfig.gopls.setup({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            gofumpt = true,
            staticcheck = true,
          },
        },
      })
    end,
  },

  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'nvim-treesitter/nvim-treesitter',
    },
    ft = { 'go', 'gomod', 'gowork', 'gotmpl' },
    opts = {
      gofmt = 'gofumpt',
      lsp_inlay_hints = { enable = true },
      lsp_document_formatting = true,
      trouble = false,
    },
    config = function(_, opts)
      require('go').setup(opts)
      local go_group = vim.api.nvim_create_augroup('dotfiles_go', { clear = true })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = go_group,
        pattern = '*.go',
        callback = function()
          require('go.format').goimport()
        end,
      })
    end,
  },
}, {
  install = { colorscheme = { 'ef-dream', 'habamax' } },
  change_detection = { notify = false },
  ui = { border = 'rounded' },
})
