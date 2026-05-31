local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { dir = vim.fn.expand("~/code/golisp-language/editors/neovim") },
  {
    "echasnovski/mini.pick",
    version = false,
    config = function()
      require("mini.pick").setup()
    end,
  },
  {
    "echasnovski/mini.extra",
    version = false,
    config = function()
      require("mini.extra").setup()
    end,
  },
  { "mfussenegger/nvim-dap" },
  {
    "leinonen/ef-dream.nvim",
    priority = 1000,
    config = function()
      require("ef-dream").setup({})
      vim.cmd.colorscheme("ef-dream")
    end,
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
  },
})
