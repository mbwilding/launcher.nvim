local M = {}

local icon = " "
local ft = "zig"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        match = { type = "directory", pattern = "build.zig" },
        commands = {
            run = "zig build run",
            build = "zig build",
        },
    },
    {
        icon = icon,
        ft = ft,
        match = { type = "file", pattern = ".zig" },
        commands = {
            run = "zig run",
            build = "zig build",
        },
    },
}

return M
