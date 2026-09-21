vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
})

local web_ft = {
  "javascript", "javascriptreact", "typescript", "typescriptreact",
  "json", "jsonc", "css",
}

local servers = {
  -- local Go Lisp language server, see ~/code/golisp-language
  glisp = {
    cmd          = { "glisp-lsp" },
    filetypes    = { "glsp" },
    root_markers = { "go.mod", ".git" },
  },

  gopls = {
    cmd       = { "gopls" },
    filetypes = { "go", "gomod", "gowork" },
    settings  = { gopls = { gofumpt = true, staticcheck = true } },
  },

  -- TypeScript 7 native language server (npm i -g typescript)
  tsgo = {
    cmd          = { "tsc", "--lsp", "--stdio" },
    filetypes    = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  },

  cssls = {
    cmd          = { "vscode-css-language-server", "--stdio" },
    filetypes    = { "css", "scss", "less" },
    root_markers = { "package.json", ".git" },
  },

  -- prefer project-local biome, fall back to global
  biome = {
    cmd = function(dispatchers, config)
      local bin = (config.root_dir or vim.fn.getcwd()) .. "/node_modules/.bin/biome"
      if vim.fn.executable(bin) ~= 1 then bin = "biome" end
      return vim.lsp.rpc.start({ bin, "lsp-proxy" }, dispatchers)
    end,
    filetypes          = web_ft,
    root_markers       = { "biome.json", "biome.jsonc" },
    workspace_required = true,
  },

  -- npm i -g yaml-language-server
  yamlls = {
    cmd          = { "yaml-language-server", "--stdio" },
    filetypes    = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    root_markers = { ".git" },
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        validate    = true,
        format      = { enable = true },
        schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
        keyOrdering = false,
      },
    },
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

local group = vim.api.nvim_create_augroup("UserLsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local b = vim.lsp.buf
    local map = function(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf })
    end

    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })

    map("i", "<C-Space>", "<C-x><C-o>")
    map("i", "<C-e>",     "<C-x><C-z>")
    map("n", "gd",         b.definition)
    map("n", "K",          b.hover)
    map("n", "<leader>rn", b.rename)
    map("n", "<leader>ca", b.code_action)
    map("n", "<leader>f",  function()
      b.format({ async = true, filter = function(c) return c.name ~= "tsgo" and c.name ~= "cssls" end })
    end)
  end,
})

-- format on save --------------------------------------------------------

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    vim.lsp.buf.format({ async = false })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = { "*.yaml", "*.yml" },
  callback = function(ev)
    vim.lsp.buf.format({ bufnr = ev.buf, async = false, name = "yamlls" })
  end,
})

-- biome: organize imports + format on save (only when biome attached)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_clients({ bufnr = ev.buf, name = "biome" })[1]
    if not client then return end
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = { only = { "source.organizeImports.biome" }, diagnostics = {} }
    local res = client:request_sync("textDocument/codeAction", params, 1000, ev.buf)
    for _, action in ipairs(res and res.result or {}) do
      if not action.edit then
        local r = client:request_sync("codeAction/resolve", action, 1000, ev.buf)
        action = r and r.result or action
      end
      if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding) end
    end
    vim.lsp.buf.format({ bufnr = ev.buf, async = false, name = "biome" })
  end,
})
