local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.register_icon = function()
    local ok, unreal_helpers = pcall(require, "unrealengine.helpers")
    if ok then
        unreal_helpers.register_icon()
    end
end

local function not_installed_error()
    error("Install 'mbwilding/UnrealEngine.nvim'")
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
                    not_installed_error()
                end
            end,
            build = function(opts)
                local ok, unreal_commands = pcall(require, "unrealengine.commands")
                if ok then
                    unreal_commands.build({
                        uproject_path = opts.file_path_absolute,
                    })
                else
                    not_installed_error()
                end
            end,
            clean = function(opts)
                local ok, unreal_commands = pcall(require, "unrealengine.commands")
                if ok then
                    unreal_commands.clean({
                        uproject_path = opts.file_path_absolute,
                    })
                else
                    not_installed_error()
                end
            end,
        },
    },
}

return M
