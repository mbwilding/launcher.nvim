local icon = " "
local ft = "lua"
local exe = "stylua"

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = icon,
            ft = ft,
            required_exe = exe,
            commands = {
                stylua = function(file)
                    return exe .. " " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
