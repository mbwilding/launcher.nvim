local icon = " "
local exe = "make"
local ft = "Makefile"
local file_pattern = ft

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        -- Generic
        {
            icon = icon,
            ft = ft,
            file_pattern = ft,
            cd = true,
            close_on_success = false,
            commands = {
                make = exe,
            },
        },
    },
}

return M
