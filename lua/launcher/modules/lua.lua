local icon = " "
local ft = "lua"
local exe = ft

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = icon,
            ft = ft,
            commands = {
                run = function(file)
                    return exe .. " " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
