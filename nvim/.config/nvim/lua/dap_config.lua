local dap = require("dap")

dap.adapters.go = {
  type = "server",
  port = "${port}",
  executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}

dap.configurations.go = {
  { type = "go", name = "Debug",         request = "launch", program = "${file}" },
  { type = "go", name = "Debug package", request = "launch", program = "${fileDirname}" },
  { type = "go", name = "Debug test",    request = "launch", program = "${file}", mode = "test" },
  { type = "go", name = "Attach",        request = "attach", processId = require("dap.utils").pick_process },
}

local m = function(k, f, d) vim.keymap.set("n", k, f, { desc = d }) end
m("<F5>",        dap.continue,          "Debug: continue")
m("<F10>",       dap.step_over,         "Debug: step over")
m("<F11>",       dap.step_into,         "Debug: step into")
m("<F12>",       dap.step_out,          "Debug: step out")
m("<leader>db",  dap.toggle_breakpoint, "Debug: toggle breakpoint")
m("<leader>dr",  dap.repl.open,         "Debug: open REPL")
