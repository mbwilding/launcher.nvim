---@type Launcher.Module
local M = {
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
