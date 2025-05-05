---@type Launcher.Module
local M = {
    definitions = {
        {
            icon = "󰨊 ",
            ft = "ps1",
            cwd = true,
            commands = {
                run = function(file)
                    return "pwsh " .. file.path_absolute_dq
                end,
            },
        },
    }
}

return M
