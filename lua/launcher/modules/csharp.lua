local M = {}

local icon = "󰌛 "

M.definitions = {
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
            run = function(opts)
                return "dotnet run --interactive --project " .. '"' .. opts.file_path_absolute .. '"'
            end,
            build = function(opts)
                return "dotnet build --interactive --project " .. '"' .. opts.file_path_absolute .. '"'
            end,
            restore = function(opts)
                return "dotnet restore --interactive " .. '"' .. opts.file_path_absolute .. '"'
            end,
        },
    },
}

return M
-- return "pwsh " .. '"' .. opts.file_path_absolute .. '"'
