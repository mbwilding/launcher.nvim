local M = {}

local icon = "󰌛 "
local ft = "cs"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        match = { type = "file", pattern = ".sln" },
        commands = {
            run = "dotnet run --no-restore --no-build",
            build = "dotnet build --no-restore",
            restore = "dotnet restore",
            watch = "dotnet watch",
            ["watch-non-interactive"] = "dotnet watch --non-interactive",
        },
    },
    {
        icon = icon,
        ft = ft,
        match = { type = "directory", pattern = ".csproj" },
        commands = {
            run = "dotnet run --no-restore --no-build --project",
            build = "dotnet build --no-restore --project",
            restore = "dotnet restore --project",
        },
    },
}

return M
