local M = {}

M.language = " "

M.handlers = {
    {
        extension = "zig",
        commands = {
            run = {
                command = "zig build run",
                pass_path = false,
            },
            build = {
                command = "zig build",
                pass_path = false,
            },
        },
    },
}

return M
