local picker = require("snacks.picker")

local M = {}

local function get_files()
    return require("plenary.scandir").scan_dir(".", {
        hidden = true,
        add_dirs = false,
        silent = true,
        respect_gitignore = true,
    })
end

local function get_language_handlers()
    local language_handlers = {}
    local source = debug.getinfo(1, "S").source:sub(2)
    local current_dir = source:match("^(.*[/\\])")
    local base_path = current_dir .. "languages"
    local files = vim.fn.globpath(base_path, "*.lua", false, true)
    for _, file in ipairs(files) do
        local module = dofile(file)
        if module.language and module.handlers then
            language_handlers[module.language] = module.handlers
        end
    end
    return language_handlers
end

local function get_relevant_files(files, handlers)
    local extSet = {}
    for _, handler_list in pairs(handlers) do
        for _, handler in ipairs(handler_list) do
            extSet[handler.extension] = true
        end
    end
    local matchingFiles = {}
    for _, file in ipairs(files) do
        local ext = file:match("^.+%.(.+)$")
        if ext and extSet[ext] then
            table.insert(matchingFiles, file)
        end
    end
    return matchingFiles
end

local function get_cross_reference(files, handlers)
    local cross_reference = {}

    -- Merge commands and language info per extension
    for lang, handler_list in pairs(handlers) do
        for _, handler in ipairs(handler_list) do
            local ext = handler.extension
            if not cross_reference[ext] then
                cross_reference[ext] = {
                    extension = ext,
                    language = lang,
                    commands = {},
                    files = {}
                }
            end
            for name, cmd in pairs(handler.commands or {}) do
                cross_reference[ext].commands[name] = cmd
            end
        end
    end

    for _, file in ipairs(files) do
        local ext = file:match("^.+%.(.+)$")
        if ext and cross_reference[ext] then
            table.insert(cross_reference[ext].files, file)
        end
    end

    return cross_reference
end

local function build_picker_entries(cross_ref)
    local entries = {}
    for ext, data in pairs(cross_ref) do
        for _, file in ipairs(data.files) do
            local file_filtered = file:gsub("^%./", "")
            local entry = {
                display = string.format("%s %s", data.language, file_filtered),
                file = file,
                file_filtered = file_filtered,
                extension = ext,
                language = data.language,
                commands = data.commands
            }
            table.insert(entries, entry)
        end
    end
    return entries
end

local function open_picker(prompt, items, format_item, on_select)
    picker.select(items, {
        prompt = prompt,
        format_item = format_item,
    }, on_select)
end

local function show_command_picker(entry)
    local command_entries = {}

    for name, cmd in pairs(entry.commands) do
        local computed_command
        if cmd.pass_path then
            computed_command = string.format('%s "%s"', cmd.command, entry.file)
        else
            computed_command = cmd.command
        end

        if cmd.set_cwd then
            local dir = entry.file:match("(.*/)")
            if dir then
                computed_command = string.format("cd %s && %s", dir, computed_command)
            end
        end

        table.insert(command_entries, {
            display = name,
            name = name,
            computed_command = computed_command,
            file = entry.file,
        })
    end

    open_picker(
        string.format("Pick Command for %s", entry.file_filtered),
        command_entries,
        function(item)
            return item.display
        end,
        function(selected)
            if selected then
                local terminal = require("toggleterm.terminal").Terminal
                local my_term = terminal:new({
                    cmd = selected.computed_command,
                    hidden = true,
                    direction = "horizontal",
                    close_on_exit = false
                })
                my_term:open()
            end
        end
    )
end

function M.show_file_picker()
    local files = get_files()
    local handlers = get_language_handlers()
    local relevant_files = get_relevant_files(files, handlers)
    local cross_ref = get_cross_reference(relevant_files, handlers)
    local entries = build_picker_entries(cross_ref)

    open_picker(
        "Pick File",
        entries,
        function(item)
            return item.display
        end,
        function(selected)
            if selected then
                show_command_picker(selected)
            end
        end
    )
end

return M
