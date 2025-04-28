local M = {}

local icon = " "
local ft = "go"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        commands = {
            run = function(opts)
                return "go run " .. '"' .. opts.file_path_absolute .. '"'
            end,
        },
    },
}

return M
