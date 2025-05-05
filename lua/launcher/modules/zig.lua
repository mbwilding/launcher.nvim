local icon = " "
local ft = "zig"

---@type Launcher.Module
local M = {
    definitions = {
        {
            icon = icon,
            ft = ft,
            commands = {
                run = "zig run",
                build = "zig build",
                ["build-run"] = "zig build run",
            },
        },
    }
}

return M
