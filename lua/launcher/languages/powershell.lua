local M = {}

local icon = "󰨊 "
local ft = "powershell"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        match = { type = "file", pattern = ".ps1" },
        commands = {
            run = "pwsh",
        },
    },
}

return M
