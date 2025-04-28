local M = {}

local icon = " "
local ft = "fish"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        match = { type = "file", pattern = ".fish" },
        commands = {
            run = "fish",
        },
    },
}

return M
