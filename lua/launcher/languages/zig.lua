local M = {}

M.language = " "

M.handlers = {
    {
        extension = "zig",
        commands = {
            run = {
                file_name = "main"; -- TODO: Add support
                command = "zig run",
                pass_path = true,
            },
            build = {
                file_name = "build"; -- TODO: Add support
                command = "zig build",
                set_cwd = true,
            },
        },
    },
}

return M
