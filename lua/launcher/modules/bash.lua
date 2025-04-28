local M = {}

local icon = " "
local ft = "bash"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        extensions = "sh",
        commands = {
            run = function(opts)
                return "bash " .. '"' .. opts.file_path_absolute .. '"'
            end,
        },
    },
}

return M
