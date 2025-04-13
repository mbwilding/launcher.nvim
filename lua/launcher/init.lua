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

local function get_language_definitions()
    local language_definitions = {}
    local source = debug.getinfo(1, "S").source:sub(2)
    local current_dir = source:match("^(.*[/\\])")
    local base_path = current_dir .. "languages"
    local files = vim.fn.globpath(base_path, "*.lua", false, true)
    for _, file in ipairs(files) do
        local module = dofile(file)
        local language = file:match("([^/\\]+)%.lua$")
        if language and module.definitions then
            language_definitions[language] = module
        end
    end
    return language_definitions
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

local function select_command(relative_file_path, definitions)
    local file_extension = relative_file_path:match("^([^%.]+)%.")
    local file_without_ext = relative_file_path:match("%.(.+)$")
    local file_name = file_without_ext .. "." .. file_extension
    local override = false
    local command_entries = {}

    -- First pass: Check if any directory definition exactly matches the filename.
    for _language, definition in pairs(definitions) do
        for _, def in ipairs(definition.definitions) do
            if def.match.type == "directory" and relative_file_path:match(def.match.pattern) then
                local escaped_pattern = vim.pesc(def.match.pattern)
                if relative_file_path:match(escaped_pattern) then
                    override = true
                end
            end
        end
    end

    -- Second pass: Insert command entries using filtering.
    for _language, definition in pairs(definitions) do
        for _, def in ipairs(definition.definitions) do
            if relative_file_path:match(def.match.pattern) then
                if def.match.type == "file" and override then
                    -- Skip file definitions if there's a directory override.
                else
                    for command_type, command in pairs(def.commands) do
                        local cwd = nil
                        local formatted_command

                        if def.match.type == "directory" then
                            cwd = vim.fn.getcwd() .. "/" .. (relative_file_path:match("^(.*)/") or "")
                            formatted_command = command
                        else
                            formatted_command = command .. '"' .. relative_file_path .. '"'
                        end

                        table.insert(command_entries, {
                            display = def.icon .. " " .. command_type,
                            command = formatted_command,
                            cwd = cwd,
                        })
                    end
                end
            end
        end
    end

    open_command_picker(string.format("Pick Command for %s", file_name), command_entries, function(item)
        return item.display
    end, function(selected)
        if selected then
            execute(selected)
        end
    end)
end

function M.run()
    local definitions = get_language_definitions()
    local file_types = get_file_types(definitions)

    select_file(file_types, function(file)
        select_command(file, definitions)
    end)
end

return M
