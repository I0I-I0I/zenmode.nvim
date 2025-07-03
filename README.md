# zenmode.nvim

A simple zenmode plugin for Neovim.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
local M = { "i0i-i0i/zenmode.nvim" }

M.cmd = {
    "ZenmodeToggle",
    "ZenmodeClose",
    "ZenmodeOpen"
}

---@class Opts
---@field default_width integer | nil
---@field toggle_opts table | nil
M.opts = {
    default_width = 30,
    toggle_opts = {
        nu = false,
        rnu = false,
        laststatus = 0
    }
}

M.keys = function()
    ---@class Buitlins
    ---@field toggle fun(input_width: integer | nil)
    ---@field open fun(input_width: integer | nil)
    ---@field close fun()
    local builtins = require("zenmode.nvim").builtins()

    return {
        { "<leader>zt", function() builtins.toggle() end, { silent = true } },
        { "<leader>zo", function() builtins.open() end,   { silent = true } },
        { "<leader>zc", function() builtins.close() end,  { silent = true } }
    }
end

return M
```

