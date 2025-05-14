local icon = " "
local ft = "sfd"
local exe = "fontforge"

---@type Launcher.Module
local M = {
    required_exe = exe,
    register_icon = {
        name = "FontForge",
        extension = ft,
        icon = icon,
    },
    definitions = {
        {
            icon = icon,
            ft = ft,
            commands = {
                run = function(file)
                    return exe .. " -nosplash -quiet " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
