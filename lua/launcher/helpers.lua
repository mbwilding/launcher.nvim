local M = {}

--- Default options
---@type Launcher.Opts
M.defaults = {
    close_on_success = true,
    custom_dir = nil,
}

--- States
---@type Launcher.States
M.states = {}

--- State file path
M.state_file_path = vim.fn.stdpath("data") .. "/launcher.json"

--- Get current working directory path
function M.get_cwd_key()
    local cwd = vim.fn.getcwd()
    local encoded = vim.fn.json_encode(cwd)
    return string.sub(encoded, 2, -2)
end

--- Load state
function M.load_state()
    local file = io.open(M.state_file_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local ok, decoded = pcall(vim.fn.json_decode, content)
        if ok and type(decoded) == "table" then
            M.states = decoded
            return
        end
    end

    M.states = {}
end

--- Save state
function M.save_state()
    local file = io.open(M.state_file_path, "w")
    if file then
        file:write(vim.fn.json_encode(M.states))
        file:close()
    else
        vim.notify("Launcher: Unable to write state data", "error")
    end
end

--- Execute command
---@param selected Launcher.Command
---@param opts Launcher.Opts
function M.execute(selected, opts)
    if type(selected.command) == "function" then
        selected.command(selected.args)
    else
        local key = M.get_cwd_key()
        M.states[key] = M.states[key] or {}
        M.states[key].selected = selected
        M.states[key].opts = opts
        M.save_state()

        opts = vim.tbl_extend("force", M.defaults, opts or {})

        local buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buffer, " " .. selected.display)
        vim.bo[buffer].syntax = nil
        vim.bo[buffer].modified = false

        vim.cmd("botright split")
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buffer)
        vim.cmd("startinsert")

        local job_opts = {
            term = true,
            curwin = true,
            cwd = selected.cd,
        }

        if selected.close_on_success then
            job_opts.on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local win_id = vim.fn.bufwinid(buffer)
                    if win_id ~= -1 then
                        vim.schedule(function()
                            vim.api.nvim_win_close(win_id, true)
                        end)
                    end
                end
            end
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        vim.fn.jobstart(selected.command, job_opts)
    end
end

--- Process module directory
---@param directory string
---@param modules Launcher.ModuleMap
function M.process_module_directory(directory, modules)
    local files = vim.fn.globpath(directory, "*.lua", false, true)
    for _, file in ipairs(files) do
        ---@type Launcher.Module
        local lua_module = dofile(file)
        if lua_module.register_icon and type(lua_module.register_icon) == "function" then
            lua_module.register_icon()
        end
        ---@type string
        local module_name = file:match("([^/\\]+)%.lua$")
        if module_name and lua_module.definitions then
            modules[module_name] = lua_module
        end
    end
end

--- Get module definitions
---@param opts Launcher.Opts
---@return Launcher.ModuleMap
function M.get_module_definitions(opts)
    ---@type Launcher.ModuleMap
    local modules = {}
    local source = debug.getinfo(1, "S").source:sub(2)
    local current_dir = source:match("^(.*[/\\])")
    local base_path = current_dir .. "modules"

    M.process_module_directory(base_path, modules)

    if opts and opts.custom_dir then
        M.process_module_directory(opts.custom_dir, modules)
    end

    return modules
end

--- Get file seach params
---@param modules Launcher.ModuleMap
---@return Launcher.Search
function M.get_file_search_params(modules)
    ---@type Launcher.Search
    local result = {}

    for _, module in pairs(modules) do
        for _, definition in ipairs(module.definitions) do
            if definition.ft then
                local fts = (type(definition.ft) == "table") and definition.ft or { definition.ft }
                ---@diagnostic disable-next-line: param-type-mismatch
                for _, ft in ipairs(fts) do
                    if definition.file_pattern then
                        local patterns = (type(definition.file_pattern) == "table") and definition.file_pattern
                            or { definition.file_pattern }
                        if result[ft] == nil or result[ft] == false then
                            result[ft] = {}
                        end
                        ---@diagnostic disable-next-line: param-type-mismatch
                        for _, pattern in ipairs(patterns) do
                            table.insert(result[ft], pattern)
                        end
                    else
                        if result[ft] == nil then
                            result[ft] = {}
                        end
                    end
                end
            end
        end
    end

    return result
end

--- Glob to lua pattern
---@param glob string
---@return string
function M.glob_to_pattern(glob)
    -- Escape magic characters, replacing "*" with ".*"
    local pattern = glob:gsub("([^%w])", "%%%1")
    pattern = pattern:gsub("%%%*", ".*")
    return "^" .. pattern .. "$"
end

--- Should show result
---@param file_path string
---@param file_search_params table<string, table<string>>
---@return boolean
function M.should_show_result(file_path, file_search_params)
    local file_type = vim.fn.fnamemodify(file_path, ":e")
    local patterns = file_search_params[file_type]

    if next(patterns) == nil then
        return true -- No specific patterns, so show the file
    end

    local file_name_with_ext = vim.fn.fnamemodify(file_path, ":t")
    for _, pattern in ipairs(patterns) do
        local lua_pattern = M.glob_to_pattern(pattern)
        if file_name_with_ext:match(lua_pattern) then
            return true -- The file matches one of the patterns, so show it
        end
    end

    return false -- None of the patterns matched, so don't show the file
end

--- Select file
---@param file_search_params table<string, table<string>>
---@param on_choice fun(file: any)
function M.select_file(file_search_params, on_choice)
    local file_types = {}
    for key, _ in pairs(file_search_params) do
        table.insert(file_types, key)
    end

    return Snacks.picker.pick({
        title = "Pick a file",
        ft = file_types,
        prompt = "File  ",
        source = "files",
        show_empty = false,
        matcher = {
            fuzzy = true,
            smartcase = true,
            ignorecase = true,
            sort_empty = true,
            filename_bonus = true,
            file_pos = true,
            cwd_bonus = false,
            frecency = true,
            history_bonus = true,
        },
        sort = {
            fields = { "score:desc", "#text", "idx" },
        },
        transform = function(item, _)
            return M.should_show_result(item.file, file_search_params)
        end,
        actions = {
            confirm = function(picker, item)
                picker:close()
                vim.schedule(function()
                    on_choice(item.file)
                end)
            end,
        },
    })
end

--- Open command picker
---@param title string
---@param items Launcher.Command[]
---@param format_item fun(item: Launcher.Command): string
---@param on_choice fun(items?: any, idx: any)
function M.open_command_picker(title, items, format_item, on_choice)
    ---@type snacks.picker.finder.Item[]
    local finder_items = {}
    for idx, item in ipairs(items) do
        local text = (format_item or tostring)(item)
        ---@type snacks.picker.finder.Item
        local finder_item = {
            formatted = text,
            text = idx .. " " .. text,
            item = item,
            idx = idx,
        }
        table.insert(finder_items, finder_item)
    end

    local completed = false
    return Snacks.picker.pick({
        source = "select",
        prompt = "Command  ",
        items = finder_items,
        format = Snacks.picker.format.ui_select(nil, #items),
        title = title,
        show_empty = false,
        layout = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            preview = false,
            layout = {
                height = 0,
                width = 0,
            },
        },
        actions = {
            confirm = function(picker, item)
                if completed then
                    return
                end
                completed = true
                picker:close()
                vim.schedule(function()
                    on_choice(item and item.item, item and item.idx)
                end)
            end,
        },
        on_close = function()
            if completed then
                return
            end
            completed = true
            vim.schedule(on_choice)
        end,
    })
end

--- Is extension a match
---@param file_extension string
---@param extensions string|string[]
---@return boolean
function M.is_extension_a_match(file_extension, extensions)
    if type(extensions) == "table" then
        for _, ext in ipairs(extensions) do
            if file_extension == ext then
                return true
            end
        end
        return false
    else
        return file_extension == extensions
    end
end

--- Wraps the string in a string
---@param in_string string The string to wrap
---@param wrap_string string The wrap string
---@return string
function M.wrap(in_string, wrap_string)
    if in_string == nil or in_string == "" then
        return ""
    end
    return wrap_string .. in_string .. wrap_string
end

--- Wraps the string in '
---@param in_string string The string to wrap
---@return string
function M.wrap_sq(in_string)
    return M.wrap(in_string, "'")
end

--- Wraps the string in "
---@param in_string string The string to wrap
---@return string
function M.wrap_dq(in_string)
    return M.wrap(in_string, '"')
end

--- Select command
---@param file_path_relative string
---@param modules Launcher.ModuleMap
---@param opts Launcher.ModuleMap
function M.select_command(file_path_relative, modules, opts)
    opts = vim.tbl_extend("force", M.defaults, opts or {})

    local file_path_absolute = vim.fn.fnamemodify(file_path_relative, ":p")
    local file_directory = vim.fn.fnamemodify(file_path_absolute, ":h")
    local file_extension = vim.fn.fnamemodify(file_path_absolute, ":e")
    local file_name_without_extension = vim.fn.fnamemodify(file_path_absolute, ":t:r")
    local file_name = vim.fn.fnamemodify(file_path_absolute, ":t")

    ---@type Launcher.Command[]
    local command_entries = {}

    for _, module in pairs(modules) do
        for module_idx, definition in ipairs(module.definitions) do
            local close_on_success = definition.close_on_success
            if close_on_success == nil then
                close_on_success = opts.close_on_success
            end

            local applicable = false
            if definition.file_pattern then
                ---@type string[]
                ---@diagnostic disable-next-line: assign-type-mismatch
                local patterns = type(definition.file_pattern) == "table" and definition.file_pattern
                    or { definition.file_pattern }
                for _, pattern in ipairs(patterns) do
                    local lua_pattern = M.glob_to_pattern(pattern)
                    if file_name:match(lua_pattern) then
                        applicable = true
                        break
                    end
                end
            else
                applicable = M.is_extension_a_match(file_extension, definition.ft)
            end

            if applicable then
                local cd = definition.cd and file_directory or vim.fn.getcwd()

                ---@type Launcher.File
                local args = {
                    path_relative = file_path_relative,
                    path_relative_sq = M.wrap_sq(file_path_relative),
                    path_relative_dq = M.wrap_dq(file_path_relative),
                    path_absolute = file_path_absolute,
                    path_absolute_sq = M.wrap_sq(file_path_absolute),
                    path_absolute_dq = M.wrap_dq(file_path_absolute),
                    directory = file_directory,
                    directory_sq = M.wrap_sq(file_directory),
                    directory_dq = M.wrap_dq(file_directory),
                    extension = file_extension,
                    name = file_name,
                    name_sq = M.wrap_sq(file_name),
                    name_dq = M.wrap_dq(file_name),
                    name_without_extension = file_name_without_extension,
                    name_without_extension_sq = M.wrap_sq(file_name_without_extension),
                    name_without_extension_dq = M.wrap_dq(file_name_without_extension),
                }

                if type(definition.commands) == "function" then
                    local commands = definition.commands(args)
                    for command_name, command in pairs(commands) do
                        ---@type Launcher.Command
                        local cmd = {
                            display = definition.icon .. command_name,
                            command = command,
                            cd = cd,
                            close_on_success = close_on_success,
                        }
                        table.insert(command_entries, cmd)
                    end
                elseif type(definition.commands) == "table" then
                    ---@diagnostic disable-next-line: param-type-mismatch
                    for command_name, command in pairs(definition.commands) do
                        if type(command) == "function" then
                            if definition.lua_only then
                                ---@type Launcher.Command
                                local cmd = {
                                    display = definition.icon .. command_name,
                                    command = command,
                                    cd = cd,
                                    args = args,
                                    close_on_success = close_on_success,
                                }
                                table.insert(command_entries, cmd)
                            else
                                local result = command(args)
                                ---@type Launcher.Command
                                local cmd = {
                                    display = definition.icon .. command_name,
                                    command = result,
                                    cd = cd,
                                    close_on_success = close_on_success,
                                }
                                table.insert(command_entries, cmd)
                            end
                        elseif type(command) == "string" then
                            ---@type Launcher.Command
                            local cmd = {
                                display = definition.icon .. command_name,
                                command = command,
                                cd = cd,
                                close_on_success = close_on_success,
                            }
                            table.insert(command_entries, cmd)
                        else
                            error(
                                "Expected a function or string in module index '"
                                    .. module_idx
                                    .. "' for command '"
                                    .. command_name
                                    .. "', but got "
                                    .. type(command)
                            )
                        end
                    end
                end
            end
        end
    end

    M.open_command_picker("Pick command for " .. file_name, command_entries, function(item)
        return item.display
    end, function(selected)
        if selected then
            M.execute(selected, opts)
        end
    end)
end

return M
