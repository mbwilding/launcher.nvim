local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.register_icon = function()
    require("nvim-web-devicons").set_icon({
        [ft] = {
            name = "UnrealEngine",
            icon = icon,
            color = vim.o.background == "dark" and "#ffffff" or "#000000",
        },
    })
end

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        extension = ft,
        commands = {
            generate_lsp = function(opts)
                if not vim.g.unreal_engine_path then
                    vim.g.unreal_engine_path = os.getenv("HOME")
                        .. "/dev/UnrealEngine/Engine/Build/BatchFiles/Linux/Build.sh"
                end

                if not vim.g.unreal_engine_platform then
                    vim.g.unreal_engine_platform = "Linux"
                end

                local cmd_generate = '"'
                    .. vim.g.unreal_engine_path
                    .. '" '
                    .. '-mode=GenerateClangDatabase -project="'
                    .. opts.file_path_absolute
                    .. '" -game -engine '
                    .. opts.file_name
                    .. "Editor "
                    .. vim.g.unreal_engine_platform
                    .. " Development"

                local cmd_copy = 'cp "'
                    .. vim.g.unreal_engine_path
                    .. '/compile_commands.json" "'
                    .. opts.file_directory
                    .. '/"'

                return cmd_generate .. " && " .. cmd_copy
            end,
        },
    },
}

return M
