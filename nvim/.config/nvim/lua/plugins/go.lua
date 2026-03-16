return {
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
}
