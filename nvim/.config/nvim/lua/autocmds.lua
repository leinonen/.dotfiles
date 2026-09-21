local group = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

-- soft wrap for prose; code keeps the global wrap = false
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap        = true
    vim.opt_local.linebreak   = true
    vim.opt_local.breakindent = true
  end,
})
