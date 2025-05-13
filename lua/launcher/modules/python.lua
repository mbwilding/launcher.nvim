---@type Launcher.Module
local M = {
    required_exe = "python3",
    definitions = {
        {
            icon = " ",
            ft = "py",
            cd = true,
            commands = {
                run = function(file)
                    return "python3 " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
