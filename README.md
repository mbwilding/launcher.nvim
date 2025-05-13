# Launcher.nvim

Launcher integrates a file picker that shows files that have execution logic specified.

## Install

### Lazy.nvim

```lua
return {
    "mbwilding/launcher.nvim",
    dependiencies = {
        "folke/snacks.nvim"
    },
    lazy = true,
    keys = {
        {
            "<leader>lp",
            function()
                require("launcher").file() -- Can pass in opts
            end,
            desc = "Launcher: File",
        },
        {
            "<leader>lr",
            function()
                require("launcher").rerun() -- Can pass in opts
            end,
            desc = "Launcher: Rerun",
        },
    },
}
```

## Opts

```lua
{
    -- Closes the command split if it's a success
    close_on_success = true
    -- The string path to your local modules
    custom_dir = nil
}
```
