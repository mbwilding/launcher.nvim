local icon = " "
local ft = "rs"
local exe = "cargo"

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = icon,
            ft = ft,
            commands = {
                run = exe .. " run",
                build = exe .. " build",
            },
        },
    },
}

return M
