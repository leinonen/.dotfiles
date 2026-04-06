local M = {}

local cache = {
  git_branch = "",
}

local mode_map = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  R = "REPLACE",
  t = "TERMINAL",
}

local function mode_label()
  return mode_map[vim.fn.mode()] or vim.fn.mode()
end

local function update_git_branch()
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir == "" then
    cache.git_branch = ""
    return
  end

  local git_dir = vim.fn.finddir(".git", file_dir .. ";")
  if git_dir == "" then
    cache.git_branch = ""
    return
  end

  local head_file = git_dir .. "/HEAD"
  local head = vim.fn.readfile(head_file)

  if vim.v.shell_error ~= 0 or #head == 0 then
    cache.git_branch = ""
    return
  end

  local line = head[1]
  local branch = line:match("ref: refs/heads/(.+)$")

  if branch then
    cache.git_branch = " " .. branch
  else
    cache.git_branch = ""
  end
end

local function lsp_diagnostics()
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  if errors > 0 then
    return "E:" .. errors
  end
  return ""
end

function M.statusline()
  local left = table.concat({
    " ",
    mode_label(),
    " | ",
    "%f",
    " ",
    cache.git_branch,
  })

  local right = lsp_diagnostics()

  return table.concat({
    left,
    "%=",
    right,
    right ~= "" and " " or "",
    "%l:%c ",
  })
end

function M.setup()
  vim.o.statusline = "%!v:lua.require('statusline').statusline()"

  local group = vim.api.nvim_create_augroup("MyStatusline", { clear = true })

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWritePost",
    "DirChanged",
  }, {
    group = group,
    callback = function()
      update_git_branch()
      vim.cmd("redrawstatus")
    end,
  })

  vim.api.nvim_create_autocmd({
    "DiagnosticChanged",
    "ModeChanged",
  }, {
    group = group,
    callback = function()
      vim.cmd("redrawstatus")
    end,
  })

  update_git_branch()
end

return M
