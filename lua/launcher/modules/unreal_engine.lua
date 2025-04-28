local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.register_icon = function()
    require("nvim-web-devicons").set_icon({
        [ft] = {
            name = "UnrealEngine",
            icon = icon,
            color = vim.o.background == "dark" and "#ffffff" or "#000000",
        },
    })
end

local platforms = {
    Windows = "Win64",
    Linux = "Linux",
    OSX = "Mac"
}

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        extension = ft,
        commands = {
            generate_lsp = function(opts)
                if not vim.g.unreal_engine_path then
                    local errmsg = "Please set vim.g.unreal_engine_path"
                    vim.notify(errmsg, "error")
                    error(errmsg)
                end

                local platform = platforms[jit.os]

                local script
                local cmd_copy
                local json = "/compile_commands.json"

                if jit.os ~= "Windows" then
                    script = vim.g.unreal_engine_path
                        .. "/Engine/Build/BatchFiles/"
                        .. platform
                        .. "/Build.sh"

                    cmd_copy = 'cp "' .. vim.g.unreal_engine_path .. json .. '" "' .. opts.file_directory .. json .. '"'
                else
                    script = vim.g.unreal_engine_path .. "/Engine/Build/BatchFiles/Build.bat"
                    cmd_copy = "powershell -Command \"Copy-Item -Path '"
                        .. vim.g.unreal_engine_path
                        .. json
                        .. "' -Destination '"
                        .. opts.file_directory
                        .. json
                        .. "'\""
                end

                local args = '-mode=GenerateClangDatabase -project="'
                    .. opts.file_path_absolute
                    .. '" -game -engine '
                    .. opts.file_name_without_extension
                    .. "Editor "
                    .. platform
                    .. " Development"

                return '"' .. script .. '" ' .. args .. " && " .. cmd_copy
            end,
        },
    },
}

return M
