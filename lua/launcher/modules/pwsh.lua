local exe = "pwsh"

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = "󰨊 ",
            ft = "ps1",
            cd = true,
            commands = {
                run = function(file)
                    return exe .. " " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
