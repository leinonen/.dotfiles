require("snacks").setup({
  picker = { enabled = true },
  zen = {
    toggles = { dim = true },
    win = {
      width = 100,
      wo = { number = false, relativenumber = false, colorcolumn = "" },
    },
  },
  dashboard = {
    enabled = true,
    preset = {
      header = [[
                       _           
                      (_)          
 _ __   ___  _____   ___ _ __ ___  
| '_ \ / _ \/ _ \ \ / / | '_ ` _ \ 
| | | |  __/ (_) \ V /| | | | | | |
|_| |_|\___|\___/ \_/ |_|_| |_| |_|
]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
})
