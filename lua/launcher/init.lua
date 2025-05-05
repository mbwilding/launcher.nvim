local M = {}

--- Default options
--- @type Launcher.Opts
local defaults = {
    close_on_success = true,
    custom_dir = nil,
}

local state
local state_file_path = vim.fn.stdpath("data") .. "/launcher.json"

local function get_cwd_key()
    local cwd = vim.fn.getcwd()
    local encoded = vim.fn.json_encode(cwd)
    return string.sub(encoded, 2, -2)
end

local function load_state()
    local file = io.open(state_file_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local ok, decoded = pcall(vim.fn.json_decode, content)
        if ok and type(decoded) == "table" then
            state = decoded
            return
        end
    end
    state = {}
end

local function save_state()
    local file = io.open(state_file_path, "w")
    if file then
        file:write(vim.fn.json_encode(state))
        file:close()
    else
        vim.notify("Launcher: Unable to write state data", "error")
    end
end

local function execute(selected, opts)
    if type(selected.command) == "function" then
        selected.command(selected.args)
    else
        local key = get_cwd_key()
        state[key] = state[key] or {}
        state[key].selected = selected
        state[key].opts = opts
        save_state()

        opts = vim.tbl_extend("force", defaults, opts or {})

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

        vim.fn.jobstart(selected.command, job_opts)
    end
end

local function process_module_directory(directory, definitions)
    local files = vim.fn.globpath(directory, "*.lua", false, true)
    for _, file in ipairs(files) do
        local lua_module = dofile(file)
        if lua_module.register_icon and type(lua_module.register_icon) == "function" then
            lua_module.register_icon()
        end
        local module_name = file:match("([^/\\]+)%.lua$")
        if module_name and lua_module.definitions then
            definitions[module_name] = lua_module
        end
    end
end

local function get_module_definitions(opts)
    local definitions = {}
    local source = debug.getinfo(1, "S").source:sub(2)
    local current_dir = source:match("^(.*[/\\])")
    local base_path = current_dir .. "modules"

    process_module_directory(base_path, definitions)

    if opts and opts.custom_dir then
        process_module_directory(opts.custom_dir, definitions)
    end

    return definitions
end

local function get_file_search_params(definitions)
    local result = {}

    for _, module in pairs(definitions) do
        for _, definition in ipairs(module.definitions) do
            if definition.ft then
                local fts = (type(definition.ft) == "table") and definition.ft or { definition.ft }
                for _, ft in ipairs(fts) do
                    if definition.file_pattern then
                        local patterns = (type(definition.file_pattern) == "table") and definition.file_pattern or
                            { definition.file_pattern }
                        if result[ft] == nil or result[ft] == false then
                            result[ft] = {}
                        end
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

local function glob_to_pattern(glob)
    -- Escape magic characters, replacing "*" with ".*"
    local pattern = glob:gsub("([^%w])", "%%%1")
    pattern = pattern:gsub("%%%*", ".*")
    return "^" .. pattern .. "$"
end

local function should_show_result(file_path, file_search_params)
    local file_type = vim.fn.fnamemodify(file_path, ":e")
    local patterns = file_search_params[file_type]

    if next(patterns) == nil then
        return true -- No specific patterns, so show the file
    end

    local file_name_with_ext = vim.fn.fnamemodify(file_path, ":t")
    for _, pattern in ipairs(patterns) do
        local lua_pattern = glob_to_pattern(pattern)
        if file_name_with_ext:match(lua_pattern) then
            return true -- The file matches one of the patterns, so show it
        end
    end

    return false -- None of the patterns matched, so don't show the file
end

local function select_file(file_search_params, on_choice, opts)
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
        transform = function(item, ctx)
            return should_show_result(item.file, file_search_params)
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

local function open_command_picker(title, items, format_item, on_choice)
    local finder_items = {}
    for idx, item in ipairs(items) do
        local text = (format_item or tostring)(item)
        table.insert(finder_items, {
            formatted = text,
            text = idx .. " " .. text,
            item = item,
            idx = idx,
        })
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

local function is_extension_match(file_extension, extensions)
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

local function select_command(file_path_relative, definitions, opts)
    opts = vim.tbl_extend("force", defaults, opts or {})

    local file_path_absolute = vim.fn.fnamemodify(file_path_relative, ":p")
    local file_directory = vim.fn.fnamemodify(file_path_absolute, ":h")
    local file_extension = vim.fn.fnamemodify(file_path_absolute, ":e")
    local file_name_without_extension = vim.fn.fnamemodify(file_path_absolute, ":t:r")
    local file_name = vim.fn.fnamemodify(file_path_absolute, ":t")

    local command_entries = {}

    for _, definition in pairs(definitions) do
        for module, def in ipairs(definition.definitions) do
            local close_on_success = def.close_on_success
            if close_on_success == nil then
                close_on_success = opts.close_on_success
            end

            local applicable = false
            if def.file_pattern then
                local patterns = type(def.file_pattern) == "table" and def.file_pattern or { def.file_pattern }
                for _, pattern in ipairs(patterns) do
                    local lua_pattern = glob_to_pattern(pattern)
                    if file_name:match(lua_pattern) then
                        applicable = true
                        break
                    end
                end
            else
                applicable = is_extension_match(file_extension, def.ft)
            end

            if applicable then
                local cwd = def.cwd and file_directory or vim.fn.getcwd()
                for command_name, command in pairs(def.commands) do
                    if type(command) == "function" then
                        ---@type Launcher.File
                        local args = {
                            path_relative = file_path_relative,
                            path_relative_sq = "'" .. file_path_relative .. "'",
                            path_relative_dq = '"' .. file_path_relative .. '"',
                            path_absolute = file_path_absolute,
                            path_absolute_sq = "'" .. file_path_absolute .. "'",
                            path_absolute_dq = '"' .. file_path_absolute .. '"',
                            directory = file_directory,
                            directory_sq = "'" .. file_directory .. "'",
                            directory_dq = '"' .. file_directory .. '"',
                            extension = file_extension,
                            name = file_name,
                            name_sq = "'" .. file_name .. "'",
                            name_dq = '"' .. file_name .. '"',
                            name_without_extension = file_name_without_extension,
                            name_without_extension_sq = "'" .. file_name_without_extension .. "'",
                            name_without_extension_dq = '"' .. file_name_without_extension .. '"',
                        }
                        if def.lua_only then
                            table.insert(command_entries, {
                                display = def.icon .. command_name,
                                command = command,
                                cwd = cwd,
                                args = args,
                                close_on_success = close_on_success,
                            })
                        else
                            local result = command(args)
                            table.insert(command_entries, {
                                display = def.icon .. command_name,
                                command = result,
                                cwd = cwd,
                                close_on_success = close_on_success,
                            })
                        end
                    elseif type(command) == "string" then
                        table.insert(command_entries, {
                            display = def.icon .. command_name,
                            command = command,
                            cwd = cwd,
                            close_on_success = close_on_success,
                        })
                    else
                        error(
                            "Expected a function or string in module '"
                            .. module
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

    open_command_picker("Pick command for " .. file_name, command_entries, function(item)
        return item.display
    end, function(selected)
        if selected then
            execute(selected, opts)
        end
    end)
end

--- @param opts Launcher.Opts Options table
function M.file(opts)
    load_state()

    local definitions = get_module_definitions(opts)
    local file_search_params = get_file_search_params(definitions)

    select_file(file_search_params, function(file)
        select_command(file, definitions, opts)
    end, opts)
end

--- @param opts Launcher.Opts Options table
function M.rerun(opts)
    load_state()

    local key = get_cwd_key()
    if state[key] and state[key].selected then
        execute(state[key].selected, opts or state[key].opts)
    else
        vim.notify("Launcher: No previous executions in the current directory", "warn")
    end
end

return M
