local icon = "󰌛 "
local exe = "dotnet"

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        {
            icon = icon,
            ft = "sln",
            cd = true,
            commands = {
                run = exe .. " run --interactive --no-restore --no-build",
                build = exe .. " build --interactive --no-restore",
                restore = exe .. " restore --interactive",
                watch = exe .. " watch --interactive",
                ["watch-non-interactive"] = exe .. " watch --interactive --non-interactive",
            },
        },
        {
            icon = icon,
            ft = "csproj",
            commands = {
                run = function(file)
                    return exe .. " run --interactive --project " .. file.path_absolute_dq
                end,
                build = function(file)
                    return exe .. " build --interactive --project " .. file.path_absolute_dq
                end,
                restore = function(file)
                    return exe .. " restore --interactive " .. file.path_absolute_dq
                end,
            },
        },
    },
}

return M
