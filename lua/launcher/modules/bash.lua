---@type Launcher.Module
local M = {
    definitions = {
        {
            icon = " ",
            ft = "sh",
            cwd = true,
            commands = {
                run = function(file)
                    return "bash " .. file.path_absolute_dq
                end,
            },
        },
    }
}

return M
