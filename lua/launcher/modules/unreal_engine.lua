local M = {}

local icon = "󰦱 "
local ft = "uproject"

M.definitions = {
    {
        icon = icon,
        ft = ft,
        cwd = true,
        commands = {
            lsp = function(opts)
                print(vim.inspect(opts))
                return 'echo "hello"'
                -- return '~/dev/UnrealEngine/Engine/Build/BatchFiles/Linux/Build.sh -mode=GenerateClangDatabase -project="{{ file }}" -game -engine HexEditor Linux Development'
            end,
        },
    },
}

return M
