local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        extension = ft,
        commands = {
            lsp = function(opts)
                -- TODO: Find path or get consumer to set a global var with path
                local home = os.getenv("HOME")
                local engine_path = home .. "/dev/UnrealEngine/Engine/Build/BatchFiles/Linux/Build.sh"
                local cmd = 'set -eax && "' .. engine_path .. '" ' ..
                    '-mode=GenerateClangDatabase -project="' ..
                    opts.file_path_absolute .. '" -game -engine HexEditor Linux Development'
                return cmd
                -- .. ' && cp "'
                -- .. engine_path
                -- .. '/compile_commands.json" "'
                -- .. opts.file_path_absolute
                -- .. '"'
            end,
        },
    },
}

return M
