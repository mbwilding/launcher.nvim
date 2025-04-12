local M = {}

M.language = "󰌛 "

M.handlers = {
    {
        extension = "sln",
        commands = {
            run = {
                command = "dotnet run --no-restore --no-build",
                pass_path = true,
            },
            build = {
                command = "dotnet build --no-restore",
                pass_path = true,
            },
            restore = {
                command = "dotnet restore",
                pass_path = true,
            },
            watch = {
                command = "dotnet watch",
            },
            ["watch-non-interactive"] = {
                command = "dotnet watch --non-interactive",
            },
        },
    },
    {
        extension = "csproj",
        commands = {
            run = {
                command = "dotnet run --no-restore --no-build --project",
                pass_path = true,
            },
            build = {
                command = "dotnet build --no-restore --project",
                pass_path = true,
            },
            restore = {
                command = "dotnet restore --project",
                pass_path = true,
            },
        },
    },
}

return M
