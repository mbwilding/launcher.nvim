local ft = "go"
local exe = ft

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = " ",
            ft = ft,
            cd = true,
            commands = {
                run = function(file)
                    return exe .. " run " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
