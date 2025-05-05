local M = {}

local icon = " "
local ft = "yaml"

local function call_command_root(args)
    return function(opts)
        return "pulumi --cwd " .. opts.file_directory_dq .. " " .. args
    end
end

local function call_command_stack(args)
    return function(opts)
        local stack = opts.file_name:match("%.(.-)%.")
        return "pulumi --cwd " .. opts.file_directory_dq .. " " .. args .. " --stack " .. stack
    end
end

M.definitions = {
    {
        icon = icon,
        ft = ft,
        file_pattern = "Pulumi.yaml",
        cwd = true,
        close_on_success = false,
        commands = {
            install = call_command_root("install"),
            up = call_command_root("up"),
            ["up skip"] = call_command_root("up --skip-preview"),
            preview = call_command_root("preview"),
            version = call_command_root("version"),
        },
    },
    {
        icon = icon,
        ft = ft,
        file_pattern = "Pulumi.*.yaml",
        cwd = true,
        close_on_success = false,
        commands = {
            up = call_command_root("up"),
            ["up skip"] = call_command_root("up --skip-preview"),
            preview = call_command_root("preview"),
        },
    },
}

return M
