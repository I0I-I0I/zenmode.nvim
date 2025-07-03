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
    ---@class Buitlin
    ---@field toggle fun(input_width: integer | nil)
    ---@field open fun(input_width: integer | nil)
    ---@field close fun()
    local builtin = require("zenmode.nvim").builtin()

    return {
        { "<leader>zt", function() builtin.toggle() end, { silent = true } },
        { "<leader>zo", function() builtin.open() end,   { silent = true } },
        { "<leader>zc", function() builtin.close() end,  { silent = true } }
    }
end

return M
```

## TODOS

- [x] listener on tab open and close events
- [ ] ignore
- [x] on\_open and on\_close
- [ ] backdrop
