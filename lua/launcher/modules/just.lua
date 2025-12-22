local icon = "󰰆 "
local exe = "just"
local ft = "Justfile"
local file_pattern = ft

---@type Launcher.Module
local M = {
    required_exe = exe,
    definitions = {
        -- -- Generic
        -- {
        --     icon = icon,
        --     ft = ft,
        --     file_pattern = ft,
        --     cd = true,
        --     close_on_success = true,
        --     commands = {
        --         just = exe,
        --     },
        -- },
        -- Specific
        {
            icon = icon,
            ft = ft,
            file_pattern = file_pattern,
            cd = true,
            close_on_success = false,
            commands = function(file)
                local targets = {}

                local f = io.open(file.path_absolute, "r")
                if not f then
                    return targets
                end

                for line in f:lines() do
                    -- Match valid just targets: non-indented, no dot, hash, or underscore (comment or private) at start
                    -- e.g. target: ... or target := ...
                    local target = line:match("^([%w_%-%:]+)%s*:?=") or line:match("^([%w_%-%:]+):")
                    if target and not target:match("^[%.#_]") then
                        -- Avoid duplicates, overwrite to get the last one
                        targets["just: " .. target] = exe .. " " .. target
                    end
                end
                f:close()

                return targets
            end,
        },
    },
}

return M
