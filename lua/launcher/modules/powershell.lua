local M = {}

M.definitions = {
    {
        icon = "󰨊 ",
        ft = "powershell",
        cwd = true,
        extension = "ps1",
        commands = {
            run = function(opts)
                return "pwsh " .. '"' .. opts.file_path_absolute .. '"'
            end,
        },
    },
}

return M
