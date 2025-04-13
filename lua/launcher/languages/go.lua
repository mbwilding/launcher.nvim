local M = {}

local icon = " "
local ft = "go"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        match = { type = "file", pattern = ".go" },
        commands = {
            run = "go run",
        },
    },
}

return M
