local M = {}

local defaults = {
    close_on_success = true,
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

local function get_module_definitions()
    local definitions = {}
    local source = debug.getinfo(1, "S").source:sub(2)
    local current_dir = source:match("^(.*[/\\])")
    local base_path = current_dir .. "modules"
    local files = vim.fn.globpath(base_path, "*.lua", false, true)
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
    return definitions
end

local function get_file_search_parameters(definitions)
    local unique_file_type = {}
    for _, module in pairs(definitions) do
        for _, definition in ipairs(module.definitions) do
            if definition.ft then
                if type(definition.ft) == "table" then
                    for _, ft in ipairs(definition.ft) do
                        unique_file_type[ft] = true
                    end
                else
                    unique_file_type[definition.ft] = true
                end
            end
        end
    end

    local file_types = {}
    for file_type in pairs(unique_file_type) do
        table.insert(file_types, file_type)
    end

    return {
        file_types = file_types,
    }
end

local function select_file(file_search_params, on_choice, opts)
    return Snacks.picker.pick({
        title = "Pick a file",
        ft = file_search_params.file_types,
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
        -- TODO: (field) transform: (string|fun(item: snacks.picker.finder.Item, ctx: snacks.picker.finder.ctx):boolean|snacks.picker.finder.Item|nil)?
        transform = function(item, ctx)
            return true
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
            print(close_on_success)
            if is_extension_match(file_extension, def.ft) then
                local cwd = def.cwd and file_directory or vim.fn.getcwd()
                for command_name, command in pairs(def.commands) do
                    if type(command) == "function" then
                        local args = {
                            file_path_relative = file_path_relative,
                            file_path_relative_sq = "'" .. file_path_relative .. "'",
                            file_path_relative_dq = '"' .. file_path_relative .. '"',
                            file_path_absolute = file_path_absolute,
                            file_path_absolute_sq = "'" .. file_path_absolute .. "'",
                            file_path_absolute_dq = '"' .. file_path_absolute .. '"',
                            file_directory = file_directory,
                            file_directory_sq = "'" .. file_directory .. "'",
                            file_directory_dq = '"' .. file_directory .. '"',
                            file_extension = file_extension,
                            file_name = file_name,
                            file_name_sq = "'" .. file_name .. "'",
                            file_name_dq = '"' .. file_name .. '"',
                            file_name_without_extension = file_name_without_extension,
                            file_name_without_extension_sq = "'" .. file_name_without_extension .. "'",
                            file_name_without_extension_dq = '"' .. file_name_without_extension .. '"',
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

function M.file(opts)
    load_state()

    local definitions = get_module_definitions()
    local file_search_params = get_file_search_parameters(definitions)

    select_file(file_search_params, function(file)
        select_command(file, definitions, opts)
    end, opts)
end

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
