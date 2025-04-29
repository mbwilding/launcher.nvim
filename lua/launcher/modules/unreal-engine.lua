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

local function check_variables()
    if not vim.g.unreal_engine_path then
        local errmsg = "Please set vim.g.unreal_engine_path"
        vim.notify(errmsg, "error")
        error(errmsg)
    end
end

local function get_platform()
    local platforms = {
        Windows = "Win64",
        Linux = "Linux",
        OSX = "Mac",
    }

    return platforms[jit.os]
end

local function get_build_script_path(platform)
    if jit.os ~= "Windows" then
        return vim.g.unreal_engine_path .. "/Engine/Build/BatchFiles/" .. platform .. "/Build.sh"
    else
        return vim.g.unreal_engine_path .. "/Engine/Build/BatchFiles/Build.bat"
    end
end

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        commands = {
            ["generate-lsp"] = function(opts)
                check_variables()
                local platform = get_platform()
                local build_script = get_build_script_path(platform)

                local json = "/compile_commands.json"

                local args = '-mode=GenerateClangDatabase -project="'
                    .. opts.file_path_absolute
                    .. '" -game -engine '
                    .. opts.file_name_without_extension
                    .. "Editor "
                    .. platform
                    .. " Development"

                local cmd_copy
                if jit.os ~= "Windows" then
                    cmd_copy = 'cp "' .. vim.g.unreal_engine_path .. json .. '" "' .. opts.file_directory .. json .. '"'
                else
                    cmd_copy = "powershell -Command \"Copy-Item -Path '"
                        .. vim.g.unreal_engine_path
                        .. json
                        .. "' -Destination '"
                        .. opts.file_directory
                        .. json
                        .. "'\""
                end

                return '"' .. build_script .. '" ' .. args -- .. " && " .. cmd_copy
            end,
            build = function(opts)
                check_variables()
                local platform = get_platform()
                local build_script = get_build_script_path(platform)

                local args = '"'
                    .. opts.file_path_absolute
                    .. '" -game -engine '
                    .. opts.file_name_without_extension
                    .. "Editor "
                    .. platform
                    .. " Development"

                return '"' .. build_script .. '" ' .. args
            end,
        },
    },
}

return M
