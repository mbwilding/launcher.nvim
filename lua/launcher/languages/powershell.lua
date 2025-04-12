local M = {}

M.language = "󰨊 "

M.handlers = {
    {
        extension = "ps1",
        commands = {
            run = {
                command = "pswh",
                pass_path = true,
            },
        },
    },
}

return M
