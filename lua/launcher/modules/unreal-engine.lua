local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.register_icon = function()
    local ok, unreal_helpers = pcall(require, "unrealengine.helpers")
    if ok then
        unreal_helpers.register_icon()
    end
end

local function call_command(cmd)
    return function(opts)
        local ok, unreal_commands = pcall(require, "unrealengine.commands")
        if ok then
            unreal_commands[cmd]({
                uproject_path = opts.file_path_absolute,
            })
        else
            error("Install 'mbwilding/UnrealEngine.nvim'")
        end
    end
end

M.definitions = {
    {
        icon = icon,
        ft = ft,
        lua_only = true,
        commands = {
            generate_lsp = call_command("generate_lsp"),
            build = call_command("build"),
            rebuild = call_command("rebuild"),
            run = call_command("run"),
            clean = call_command("clean"),
        },
    },
}

return M
