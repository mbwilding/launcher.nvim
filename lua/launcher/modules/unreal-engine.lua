local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.register_icon = function()
    local ok, unreal_helpers = pcall(require, "unrealengine.helpers")
    if ok then
        unreal_helpers.register_icon()
    end
end

M.definitions = {
    {
        icon = icon,
        ft = ft,
        lua_only = true,
        commands = {
            ["generate-lsp"] = function(opts)
                local ok, unreal_commands = pcall(require, "unrealengine.commands")
                if ok then
                    unreal_commands.generate_lsp({
                        uproject_path = opts.file_path_absolute,
                    })
                else
                    error("Install 'mbwilding/UnrealEngine.nvim'")
                end
            end,
            build = function(opts)
                local ok, unreal_commands = pcall(require, "unrealengine.commands")
                if ok then
                    unreal_commands.build({
                        uproject_path = opts.file_path_absolute,
                    })
                else
                    error("Install 'mbwilding/UnrealEngine.nvim'")
                end
            end,
        },
    },
}

return M
