local M = {}

local icon = " "
local ft = "yaml"

local function call_command(args)
    return function(opts)
        return "pulumi --cwd " .. opts.file_directory_dq .. " " .. args
    end
end

M.definitions = {
    {
        icon = icon,
        ft = ft,
        file_pattern = {
            "Pulumi.yaml",
            -- "Pulumi.*.yaml",
        },
        cwd = true,
        close_on_success = false,
        commands = {
            install = call_command("install"),
            up = call_command("up"),
            ["up skip"] = call_command("up --skip-preview"),
            preview = call_command("preview"),
            version = call_command("version"),
        },
    },
}

return M
