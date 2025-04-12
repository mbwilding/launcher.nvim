local M = {}

M.language = " "

M.handlers = {
    {
        extension = "zig",
        commands = {
            run = {
                command = "zig build run",
                set_cwd = true,
            },
            build = {
                command = "zig build",
                set_cwd = true,
            },
        },
    },
}

return M
