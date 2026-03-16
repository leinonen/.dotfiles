local seen = {}

local function map(mode, lhs, rhs, desc)
  local key = table.concat(type(mode) == 'table' and mode or { mode }, ',') .. '::' .. lhs
  if seen[key] then
    error(('Duplicate keymap detected for %s (%s and %s)'):format(key, seen[key], desc or 'no description'))
  end

  seen[key] = desc or 'no description'
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

map('n', '<leader>w', '<cmd>write<cr>', 'Write buffer')
map('n', '<leader>q', '<cmd>quit<cr>', 'Quit window')
map('n', '<leader>h', '<cmd>nohlsearch<cr>', 'Clear search highlight')

map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', 'Find files')
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', 'Live grep')
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', 'Find buffers')

map('n', '<leader>e', vim.diagnostic.open_float, 'Line diagnostics')
map('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')

-- Go-focused commands
map('n', '<leader>gr', '<cmd>GoRun<cr>', 'Go run')
map('n', '<leader>gt', '<cmd>GoTest<cr>', 'Go test package')
map('n', '<leader>gT', '<cmd>GoTestFunc<cr>', 'Go test function')
map('n', '<leader>gi', '<cmd>GoImpl<cr>', 'Go implement interface')
map('n', '<leader>gf', '<cmd>GoFmt<cr>', 'Go format file')
