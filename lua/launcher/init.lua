local helpers = require("launcher.helpers")

local M = {}

--- File picker
---@param opts Launcher.Opts Options table
function M.file(opts)
    helpers.load_state()

    local modules = helpers.get_module_definitions(opts)
    local file_search_params = helpers.get_file_search_params(modules)

    helpers.select_file(file_search_params, function(file)
        helpers.select_command(file, modules, opts)
    end)
end

--- Re-run
---@param opts Launcher.Opts Options table
function M.rerun(opts)
    helpers.load_state()

    local key = helpers.get_cwd_key()
    if helpers.states[key] and helpers.states[key].selected then
        helpers.execute(helpers.states[key].selected, opts or helpers.states[key].opts)
    else
        vim.notify("Launcher: No previous executions in the current directory", "warn")
    end
end

return M
