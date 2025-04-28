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
                local engine_path = os.getenv("HOME") .. "/dev/UnrealEngine/Engine/Build/BatchFiles/Linux/Build.sh"
                local project_name = "Hex"

                local cmd = 'set -eax && "' .. engine_path .. '" ' ..
                    '-mode=GenerateClangDatabase -project="' ..
                    opts.file_path_absolute .. '" -game -engine ' .. project_name .. 'Editor Linux Development'

                print(cmd)
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
