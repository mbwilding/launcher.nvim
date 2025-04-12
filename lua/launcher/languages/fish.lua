local M = {}

M.language = " "

M.handlers = {
    {
        extension = "fish",
        commands = {
            run = {
                command = "fish",
                pass_path = true,
            },
        },
    },
}

return M
