local M = {}

M.definitions = {
    {
        icon = "󰨊 ",
        ft = "powershell",
        cwd = true,
        commands = {
            run = function(file)
                return "pwsh " .. '"' .. file.path .. '"'
            end,
        },
    },
}

return M
