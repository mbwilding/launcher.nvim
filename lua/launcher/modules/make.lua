local icon = " "
local exe = "make"
local file_pattern = "Makefile"
local ft = exe

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        -- Generic
        {
            icon = icon,
            ft = ft,
            file_pattern = file_pattern,
            cd = true,
            close_on_success = false,
            commands = {
                make = exe,
            },
        },
    },
}

return M
