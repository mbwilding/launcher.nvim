local icon = " "
local ft = "zig"
local exe = ft

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
                ["build-run"] = exe .. " build run",
            },
        },
    },
}

return M
