local icon = " "
local exe = "make"
local ft = "Makefile"
local file_pattern = ft

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        -- Generic
        {
            icon = icon,
            ft = ft,
            file_pattern = ft,
            cd = true,
            close_on_success = true,
            commands = {
                make = exe,
            },
        },
        -- Specific
        {
            icon = icon,
            ft = ft,
            file_pattern = file_pattern,
            cd = true,
            close_on_success = true,
            commands = function(file)
                local targets = {}

                local f = io.open(file.path_absolute, "r")
                if not f then
                    return targets
                end

                for line in f:lines() do
                    -- Match lines like 'target: deps' but not ones starting with tab, or '.PHONY'
                    local target = line:match("^([%w_%-%.]+):")
                    if target and not target:match("^%.") then
                        -- Avoid duplicates, overwrite to get the last one (which is fine for Makefiles)
                        targets["make: " .. target] = exe .. " " .. target
                    end
                end
                f:close()

                return targets
            end,
        },
    },
}

return M
