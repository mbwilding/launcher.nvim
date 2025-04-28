local M = {}

local ft = "ps1"

M.definitions = {
    {
        icon = "󰨊 ",
        ft = ft,
        cwd = true,
        commands = {
            run = function(opts)
                return "pwsh " .. '"' .. opts.file_path_absolute .. '"'
            end,
        },
    },
}

return M
