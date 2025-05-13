local icon = " "
local ft = "rs"

---@type Launcher.Module
local M = {
    required_exe = "cargo",
    definitions = {
        {
            icon = icon,
            ft = ft,
            commands = {
                run = "cargo run",
                build = "cargo build",
            },
        },
    },
}

return M
