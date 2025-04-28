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
                local platform = "Linux"

                local cmd = '"' .. engine_path .. '" ' ..
                    '-mode=GenerateClangDatabase -project="' ..
                    opts.file_path_absolute .. '" -game -engine ' .. project_name .. "Editor " .. platform .. " Development"

                print(cmd)
                print(vim.inspect(opts))

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
