local M = {}

-- local function execute(selected)
--     local terminal = require("toggleterm.terminal").Terminal
--     local my_term = terminal:new({
--         cmd = selected.command,
--         cwd = selected.cwd,
--         hidden = true,
--         direction = "horizontal",
--         close_on_exit = false,
--     })
--     my_term:open()
-- end

local function execute(selected)
    vim.cmd("botright split")
    vim.cmd("terminal " .. selected.command)
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buffer, " " .. selected.display)

    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buffer,
        once = true,
        callback = function(event)
            local win = vim.fn.bufwinid(event.buf)
            if win ~= -1 then
                vim.api.nvim_win_close(win, true)
            end
        end,
    })
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

local function get_file_types(definitions)
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
    return file_types
end

local function select_file(file_types, on_choice)
    return Snacks.picker.pick({
        title = "Pick a file",
        ft = file_types,
        prompt = "File  ",
        source = "files",
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

local last_selected
local function select_command(file_path_relative, definitions)
    local file_path_absolute = vim.fn.fnamemodify(file_path_relative, ":p")
    local file_directory = vim.fn.fnamemodify(file_path_absolute, ":h")
    local file_extension = vim.fn.fnamemodify(file_path_absolute, ":e")
    local file_name_without_extension = vim.fn.fnamemodify(file_path_absolute, ":t:r")
    local file_name = vim.fn.fnamemodify(file_path_absolute, ":t")

    local command_entries = {}

    for _, definition in pairs(definitions) do
        for module, def in ipairs(definition.definitions) do
            if is_extension_match(file_extension, def.ft) then
                local cwd = def.cwd and file_directory or vim.fn.getcwd()
                for command_name, fn in pairs(def.commands) do
                    if type(fn) ~= "function" then
                        error(
                            "Expected a function in module '"
                            .. module
                            .. "' for command '"
                            .. command_name
                            .. "', but got "
                            .. type(fn)
                        )
                    end
                    local result = fn({
                        file_path_relative = file_path_relative,
                        file_path_absolute = file_path_absolute,
                        file_directory = file_directory,
                        file_extension = file_extension,
                        file_name = file_name,
                        file_name_without_extension = file_name_without_extension,
                    })
                    table.insert(command_entries, {
                        display = def.icon .. command_name,
                        command = result,
                        cwd = cwd,
                    })
                end
            end
        end
    end

    open_command_picker("Pick command for " .. file_name, command_entries, function(item)
        return item.display
    end, function(selected)
        if selected then
            last_selected = selected
            execute(selected)
        end
    end)
end

function M.picker()
    local definitions = get_module_definitions()
    local file_types = get_file_types(definitions)

    select_file(file_types, function(file)
        select_command(file, definitions)
    end)
end

function M.rerun()
    if last_selected then
        execute(last_selected)
    end
end

return M
