local M = {}

local function execute(selected)
    local terminal = require("toggleterm.terminal").Terminal
    local my_term = terminal:new({
        cmd = selected.command,
        cwd = selected.cwd,
        hidden = true,
        direction = "horizontal",
        close_on_exit = false,
    })
    my_term:open()
end

local function get_module_definitions()
    local definitions = {}
    local source = debug.getinfo(1, "S").source:sub(2)
    local current_dir = source:match("^(.*[/\\])")
    local base_path = current_dir .. "modules"
    local files = vim.fn.globpath(base_path, "*.lua", false, true)
    for _, file in ipairs(files) do
        local lua_module = dofile(file)
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
                unique_file_type[definition.ft] = true
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

local function select_command(path, definitions)
    local directory = path:match("(.+/)")
    local extension = path:match("%.([^%.]+)$")
    local name_without_extension = path:match("%.(.+)$")
    local name = name_without_extension .. "." .. extension

    local command_entries = {}

    for _, definition in pairs(definitions) do
        for _, def in ipairs(definition.definitions) do
            local cwd = nil
            if def.match.type == "directory" then
                cwd = vim.fn.getcwd() .. "/" .. (path:match("^(.*)/") or "")
            end
            for command_name, command in pairs(def.commands) do
                table.insert(command_entries, {
                    display = def.icon .. " " .. command_name,
                    command = command({
                        path = path,
                        directory = directory,
                        extension = extension,
                        name = name,
                        name_without_extension = name_without_extension,
                    }),
                    cwd = cwd,
                })
            end
        end
    end

    open_command_picker(string.format("Pick Command for %s", name), command_entries, function(item)
        return item.display
    end, function(selected)
        if selected then
            execute(selected)
        end
    end)
end

function M.run()
    local definitions = get_module_definitions()
    local file_types = get_file_types(definitions)

    select_file(file_types, function(file)
        select_command(file, definitions)
    end)
end

return M
