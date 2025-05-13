---@type Launcher.Module
local M = {
    required_exe = "pwsh",
    definitions = {
        {
            icon = "󰨊 ",
            ft = "ps1",
            cd = true,
            commands = {
                run = function(file)
                    return "pwsh " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
