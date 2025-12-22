# launcher.nvim

Pick a file. Pick a command. Run it in a split.

`launcher.nvim` is a tiny “run menu” for Neovim: it shows you only the files that have something meaningful you can *do* (run, build, format, deploy…), then lets you choose the exact command and executes it in a terminal split.

If you’re tired of remembering whether it’s `cargo run`, `dotnet watch`, `bun run dev`, `make test`, or a one-off script path… this gives you a consistent muscle-memory workflow.

## What you get

- A fast file picker filtered to “runnable” files (powered by `folke/snacks.nvim`).
- A second picker listing the actions available for that file.
- Runs the chosen command in a bottom terminal split.
- Optional auto-close of the split on success.
- `rerun()` remembers the last selection per working directory.
- Extensible “modules” system so you can add your own actions.
- Built-in modules for common tools (Cargo, Dotnet, Bun, Make, Just, Pulumi, etc.).

## Requirements

- Neovim
- `folke/snacks.nvim` (required)
- `nvim-web-devicons` (optional, for nicer file icons)

## Install

### lazy.nvim

```lua
return {
  "mbwilding/launcher.nvim",
  dependencies = {
    "folke/snacks.nvim",
    -- "nvim-tree/nvim-web-devicons", -- optional
  },
  keys = {
    {
      "<leader>lp",
      function()
        require("launcher").file()
      end,
      desc = "Launcher: Pick file",
    },
    {
      "<leader>lr",
      function()
        require("launcher").rerun()
      end,
      desc = "Launcher: Rerun last",
    },
  },
}
```

## Usage

- `require("launcher").file(opts)`
  - Pick a file (only shows files that have matching module logic)
  - Pick a command for that file
  - Runs it in a terminal split

- `require("launcher").rerun(opts)`
  - Re-runs the last selected command for the current working directory

## Options

```lua
{
  -- Close the terminal split when the command exits 0.
  close_on_success = true,

  -- Absolute path to a directory containing your own module files.
  -- Each file should return a Launcher.Module table.
  custom_dir = nil,
}
```

## Notes

- Commands run via `vim.fn.jobstart()` in a dedicated terminal buffer.
- `rerun()` state is stored in `stdpath('data')/launcher.json` (per working directory).
