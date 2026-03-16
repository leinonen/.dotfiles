return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      defaults = {
        layout_strategy = 'horizontal',
        sorting_strategy = 'ascending',
      },
    },
  },
}
