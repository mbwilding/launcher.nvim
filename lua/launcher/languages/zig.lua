local M = {}

M.language = " "

M.handlers = {
    {
        extension = "zig",
        commands = {
            run = {
                command = "zig run",
                pass_path = true,
            },
            build = {
                command = "zig build",
                set_cwd = true,
            },
        },
    },
}

return M
