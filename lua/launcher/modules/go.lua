---@type Launcher.Module
local M = {
    required_exe = "go",
    definitions = {
        {
            icon = " ",
            ft = "go",
            cd = true,
            commands = {
                run = function(file)
                    return "go run " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
