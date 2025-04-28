local M = {}

local icon = " "
local ft = "zig"

M.definitions = {
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

return M
