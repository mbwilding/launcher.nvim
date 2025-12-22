local icon = " "
local ft = "toml"
local exe = "cargo"

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = icon,
            ft = ft,
            file_pattern = "Cargo.toml",
            cd = true,
            close_on_success = false,
            commands = {
                run = exe .. " run",
                test = exe .. " test",
                check = exe .. " check",
                clippy = exe .. " clippy",
            },
        },
        {
            icon = icon,
            ft = ft,
            file_pattern = "Cargo.toml",
            cd = true,
            close_on_success = true,
            commands = {
                build = exe .. " build",
                format = exe .. " fmt",
            },
        },
    },
}

return M
