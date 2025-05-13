local icon = " "
local ft = "yaml"

---@param args string The arguments
local function call_command_root(args)
    ---@param file Launcher.File
    return function(file)
        return "pulumi --cwd " .. file.directory_dq .. " " .. args
    end
end

---@param args string The arguments
local function call_command_stack(args)
    ---@param file Launcher.File
    return function(file)
        local stack = file.name:match("%.(.-)%.")
        return "pulumi --cwd " .. file.directory_dq .. " " .. args .. " --stack " .. stack
    end
end

---@type Launcher.Module
local M = {
    definitions = {
        {
            icon = icon,
            ft = ft,
            file_pattern = "Pulumi.yaml",
            cd = true,
            close_on_success = false,
            commands = {
                install = call_command_root("install"),
            },
        },
        {
            icon = icon,
            ft = ft,
            file_pattern = "Pulumi.*.yaml",
            cd = true,
            close_on_success = false,
            commands = {
                preview = call_command_stack("preview"),
                up = call_command_stack("up"),
                ["up skip"] = call_command_stack("up --skip-preview"),
                refresh = call_command_stack("refresh"),
                ["refresh skip"] = call_command_stack("refresh --skip-preview"),
            },
        },
    },
}

return M
