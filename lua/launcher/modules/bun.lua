---@type Launcher.Module
local M = {
    definitions = {
        {
            icon = " ",
            ft = "json",
            file_pattern = "package.json",
            cd = true,
            close_on_success = false,
            commands = function(file)
                local scripts = {}

                local f = io.open(file.path_absolute, "rb")
                if not f then
                    return scripts
                end

                local content = f:read("*a")
                f:close()

                local ok, package_data = pcall(vim.fn.json_decode, content)
                if not ok or type(package_data) ~= "table" then
                    return scripts
                end

                if package_data.scripts and type(package_data.scripts) == "table" then
                    for script_name, _ in pairs(package_data.scripts) do
                        scripts[script_name] = "bun run " .. script_name
                    end
                end

                return scripts
            end,
        },
    },
}

return M
