local icon = "󰌛 "

---@type Launcher.Module
local M = {
    definitions = {
        {
            icon = icon,
            ft = "sln",
            cwd = true,
            commands = {
                run = "dotnet run --interactive --no-restore --no-build",
                build = "dotnet build --interactive --no-restore",
                restore = "dotnet restore --interactive",
                watch = "dotnet watch --interactive",
                ["watch-non-interactive"] = "dotnet watch --interactive --non-interactive",
            },
        },
        {
            icon = icon,
            ft = "csproj",
            commands = {
                run = function(file)
                    return "dotnet run --interactive --project " .. file.path_absolute_dq
                end,
                build = function(file)
                    return "dotnet build --interactive --project " .. file.path_absolute_dq
                end,
                restore = function(file)
                    return "dotnet restore --interactive " .. file.path_absolute_dq
                end,
            },
        },
    }
}

return M
