local M = {}

local icon = "󰌛 "

M.definitions = {
    {
        icon = icon,
        ft = "sln",
        cwd = true,
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
        ft = "csproj",
        commands = {
            run = function(opts)
                return "dotnet run --no-restore --no-build --project " .. opts.file_path_absolute
            end,
            build = function(opts)
                return "dotnet build --no-restore --project " .. opts.file_path_absolute
            end,
            restore = function(opts)
                return "dotnet restore --project " .. opts.file_path_absolute
            end,
        },
    },
}

return M
-- return "pwsh " .. '"' .. opts.file_path_absolute .. '"'
