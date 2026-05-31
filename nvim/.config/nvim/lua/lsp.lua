vim.lsp.config["glisp"] = {
  cmd          = { "glisp-lsp" },
  filetypes    = { "glsp" },
  root_markers = { "go.mod", ".git" },
}
vim.lsp.enable("glisp")

vim.lsp.config("gopls", {
  cmd       = { "gopls" },
  filetypes = { "go", "gomod", "gowork" },
  settings  = { gopls = { gofumpt = true, staticcheck = true } },
})
vim.lsp.enable("gopls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local b = vim.lsp.buf
    local m = function(k, f) vim.keymap.set("n", k, f, { buffer = ev.buf }) end
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { buffer = ev.buf })
    vim.keymap.set("i", "<C-e>",     "<C-x><C-z>", { buffer = ev.buf })
    m("gd",         b.definition)
    m("K",          b.hover)
    m("<leader>rn", b.rename)
    m("<leader>ca", b.code_action)
    m("<leader>f",  function() b.format({ async = true }) end)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    vim.lsp.buf.format({ async = false })
  end,
})
