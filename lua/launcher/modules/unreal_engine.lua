local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        match = { type = "file", pattern = ".uproject" },
        commands = {
            lsp = function(file)
                print(vim.inspect(file))
                return 'echo "hello"'
                -- return '~/dev/UnrealEngine/Engine/Build/BatchFiles/Linux/Build.sh -mode=GenerateClangDatabase -project="{{ file }}" -game -engine HexEditor Linux Development'
            end,
        },
    },
}

return M
