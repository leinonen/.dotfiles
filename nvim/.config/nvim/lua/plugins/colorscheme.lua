return {
  {
    'protesilaos/ef-themes.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('ef-dream')
    end,
  },
}
