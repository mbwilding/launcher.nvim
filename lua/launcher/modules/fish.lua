local M = {}

local icon = " "
local ft = "fish"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        commands = {
            run = function(opts)
                return "fish " .. '"' .. opts.file_path_absolute .. '"'
            end,
        },
    },
}

return M
