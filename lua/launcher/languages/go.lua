local M = {}

M.language = " "

M.handlers = {
    {
        extension = "go",
        commands = {
            run = {
                command = "go run",
                pass_path = true,
            },
        },
    },
}

return M
