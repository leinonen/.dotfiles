require("gitsigns").setup({
  -- buffer-local, so these stay here rather than in lua/keymaps.lua
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local map = function(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    map("n", "]h", gs.next_hunk,               "Next hunk")
    map("n", "[h", gs.prev_hunk,               "Prev hunk")
    map("n", "<leader>hs", gs.stage_hunk,      "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk,      "Reset hunk")
    map("n", "<leader>hS", gs.stage_buffer,    "Stage buffer")
    map("n", "<leader>hR", gs.reset_buffer,    "Reset buffer")
    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
    map("n", "<leader>hp", gs.preview_hunk,    "Preview hunk")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    map("n", "<leader>hd", gs.diffthis,        "Diff this")
    map({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<CR>", "Select hunk")
  end,
})
