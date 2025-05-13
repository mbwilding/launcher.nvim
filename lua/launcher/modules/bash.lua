local exe = "bash"

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = " ",
            ft = "sh",
            cd = true,
            commands = {
                run = function(file)
                    return "bash " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
