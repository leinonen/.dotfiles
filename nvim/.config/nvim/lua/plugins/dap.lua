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
