local M = {}

M.language = " "

M.handlers = {
    {
        extension = "sh",
        commands = {
            run = {
                command = "bash",
                pass_path = true,
            },
        },
    },
}

return M
