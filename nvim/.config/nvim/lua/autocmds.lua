vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap        = true
    vim.opt_local.linebreak   = true
    vim.opt_local.breakindent = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "lua", "javascript", "typescript", "python", "rust" },
  callback = function()
    vim.opt_local.wrap      = false
    vim.opt_local.linebreak = false
  end,
})
