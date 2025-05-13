local icon = " "
local ft = "lua"

---@type Launcher.Module
local M = {
    definitions = {
        {
            icon = icon,
            ft = ft,
            required_exe = "stylua",
            commands = {
                stylua = function(file)
                    return "stylua " .. file.path_absolute_dq
                end,
            },
        },
        {
            icon = icon,
            ft = ft,
            required_exe = "lua",
            commands = {
                run = function(file)
                    return "lua " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
