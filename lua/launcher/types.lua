--- Options
---@class Launcher.Opts
---@field close_on_success? boolean Closes the command split if it's a success
---@field custom_dir? string The path to your local modules

--- File Info
---@class Launcher.File
---@field path_relative string The relative file path
---@field path_relative_sq string The relative file path enclosed in single quotes
---@field path_relative_dq string The relative file path enclosed in double quotes
---@field path_absolute string The absolute file path
---@field path_absolute_sq string The absolute file path enclosed in single quotes
---@field path_absolute_dq string The absolute file path enclosed in double quotes
---@field directory string The directory of the file
---@field directory_sq string The directory of the file enclosed in single quotes
---@field directory_dq string The directory of the file enclosed in double quotes
---@field extension string The extension of the file
---@field name string The name of the file
---@field name_sq string The file name enclosed in single quotes
---@field name_dq string The file name enclosed in double quotes
---@field name_without_extension string The file name without its extension
---@field name_without_extension_sq string The file name without extension enclosed in single quotes
---@field name_without_extension_dq string The file name without extension enclosed in double quotes

--- Module Definition
---@class Launcher.Definition
---@field icon? string Icon
---@field ft string|string[] File type
---@field cd? boolean Run command in the file's directory
---@field lua_only? boolean If the command is lua only, no returned shell command
---@field file_pattern? string File pattern that filters the commands to specific files
---@field commands table<string, (string | fun(file: Launcher.File): string|nil)>|fun(file: Launcher.File): table<string, string> Commands, mapped by name to a string or a function, can also take a function that produces a table of name/command
---@field close_on_success? boolean Closes the command split if it's a success

--- Module Definitions
---@alias Launcher.Definitions Launcher.Definition[]

--- Module
---@class Launcher.Module
---@field definitions Launcher.Definitions
---@field required_exe? string
---@field register_icon? fun() Function to register the icon

--- Module Map
---@alias Launcher.ModuleMap table<string, Launcher.Module>

--- Selected
---@class Launcher.Command
---@field display string Display string
---@field command? string|fun(args: string|Launcher.File) Command
---@field args? string|Launcher.File Command arguments
---@field cd string|fun() Directory to run in
---@field close_on_success? boolean Closes the split on command success, when true

--- State
---@class Launcher.State
---@field selected Launcher.Command
---@field opts Launcher.Opts

--- States
---@alias Launcher.States table<string, Launcher.State>

--- Search
---@alias Launcher.Search table<string, table<string>>
