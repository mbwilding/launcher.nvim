local icon = "󰦱 "
local ft = "uproject"

---@param cmd string The command
local function call_command(cmd)
    ---@param file Launcher.File
    return function(file)
        local ok, unreal = pcall(require, "unrealengine.commands")
        if ok then
            unreal[cmd]({
                uproject_path = file.path_absolute,
            })
        else
            error("Install 'mbwilding/UnrealEngine.nvim'")
        end
    end
end

---@type Launcher.Module
local M = {
    register_icon = function()
        local ok, unreal_helpers = pcall(require, "unrealengine.helpers")
        if ok then
            unreal_helpers.register_icon()
        end
    end,
    definitions = {
        {
            icon = icon,
            ft = ft,
            lua_only = true,
            commands = {
                generate_lsp = call_command("generate_lsp"),
                build = call_command("build"),
                rebuild = call_command("rebuild"),
                open = call_command("open"),
                clean = call_command("clean"),
            },
        },
    },
}

return M
