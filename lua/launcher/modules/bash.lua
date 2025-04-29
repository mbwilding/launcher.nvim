local M = {}

local icon = " "
local ft = "sh"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        commands = {
            run = function(opts)
                return "bash " .. opts.file_path_absolute_dq
            end,
        },
    },
}

return M
