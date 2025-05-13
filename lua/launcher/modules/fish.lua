---@type Launcher.Module
local M = {
    required_exe = "fish",
    definitions = {
        {
            icon = " ",
            ft = "fish",
            cd = true,
            commands = {
                run = function(file)
                    return "fish " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
