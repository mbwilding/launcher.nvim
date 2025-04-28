local M = {}

M.definitions = {
    {
        icon = "󰨊 ",
        ft = "powershell",
        cwd = true,
        commands = {
            run = function(opts)
                return "pwsh " .. '"' .. opts.file .. '"'
            end,
        },
    },
}

return M
