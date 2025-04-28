local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.register_icon = function()
    require("nvim-web-devicons").set_icon({ uproject = { icon = icon, color = "#000000", name = "Unreal Engine" } })
    print("TEST")
end

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

                local cmd_generate = '"'
                    .. engine_path
                    .. '" '
                    .. '-mode=GenerateClangDatabase -project="'
                    .. opts.file_path_absolute
                    .. '" -game -engine '
                    .. project_name
                    .. "Editor "
                    .. platform
                    .. " Development"

                local cmd_copy = 'cp "' .. engine_path .. '/compile_commands.json" "' .. opts.file_directory .. '/"'

                return cmd_generate .. " && " .. cmd_copy
            end,
        },
    },
}

return M
