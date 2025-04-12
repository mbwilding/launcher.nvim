local M = {}

M.language = " "

M.handlers = {
    {
        extension = "zig",
        commands = {
            run = {
                file_name = "main";
                command = "zig run",
                pass_path = true,
            },
            build = {
                file_name = "build";
                command = "zig build",
                set_cwd = true,
            },
        },
    },
}

return M
