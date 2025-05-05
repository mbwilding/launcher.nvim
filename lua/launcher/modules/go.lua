---@type Launcher.Module
local M = {
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
